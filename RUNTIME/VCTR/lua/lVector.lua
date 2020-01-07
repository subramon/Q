-- If not, any other string will work but do not use __ as a prefix
local ffi               = require 'ffi'
local qconsts		= require 'Q/UTILS/lua/q_consts'
local cutils            = require 'libcutils'
local cmem		= require 'libcmem'
local Scalar		= require 'libsclr'
local cVector		= require 'libvctr'
local register_type	= require 'Q/UTILS/lua/q_types'
local is_base_qtype	= require 'Q/UTILS/lua/is_base_qtype'
local chk_chunk_return	= require 'Q/UTILS/lua/chk_chunk'
local qc		= require 'Q/UTILS/lua/q_core'
local H                 = require 'Q/RUNTIME/VCTR/lua/helpers'
--====================================
local lVector = {}
lVector.__index = lVector

setmetatable(lVector, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(lVector, "lVector")

function lVector:backup()
  return H.on_both(self, cVector.backup)
end

function lVector:check()
  -- cannot use on_both here because check called from within
  assert(cVector.check(self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.check(self._nn_vec))
  end 
  return true
end

-- not from Lua. Use cVector:check_chunks()
function lVector:chunk_size_in_bytes()
  return extract_field(self, "chunk_size_in_bytes", "number")
end

function lVector:delete()
  local status = cVector.delete(self._base_vec) 
  if ( not status ) then print("Likely you are deleting dead vector") end
  if ( self._nn_vec ) then 
    status = cVector.delete(self._nn_vec) 
    if ( not status ) then print("Likely you are deleting dead vector") end
  end
  return true
end

function lVector:delete_chunk_file(chunk_num)
  return on_both(self, cVector.delete_chunk_file, chunk_num)
end

function lVector:delete_master_file()
  return H.on_both(self, cVector.delete_master_file)
end

function lVector:end_read()
  return H.on_both(self, cVector.end_read)
end

function lVector:end_write()
  return H.on_both(self, cVector.end_write)
end

function lVector:eov()
  assert(H.on_both(self, cVector.eov))
-- destroy generator (if any) and thereby 
-- (1) release resources held by it 
-- (2) no more data can be added to Vector
  self._gen = nil 
  if ( self:num_elements() == 0 ) then return nil end
  return self
end

function lVector:eval()
  if ( self:is_eov() ) then return self end 
  assert(H.is_multiple_of_chunk_size(self:num_elements()))
  local chunk_num = self:num_elements() / cVector.chunk_size
  local base_len, base_addr, nn_addr 
  repeat
    base_len, base_addr, nn_addr = self:get_chunk(chunk_num)
    chunk_num = chunk_num + 1 
  until ( base_len ~= qconsts.chunk_size )
  assert(self:is_eov())
  -- cannot have Vector with 0 elements
  if ( self:length() == 0 ) then  return nil  end
  -- 07/2019
  -- This delete() is an important change from previous implemenation.
  -- The generator that gave us the data would have allocated a CMEM
  -- Now that the Vector has been fully created, that is not needed
  -- Hence ,its okay to go ahead and delete the memory within the CMEM
  -- Note that the deletion of the CMEM itself is up to Lua
  if ( type(self._gen) == "function" ) then 
    if (    base_addr ) then    base_addr:delete() end 
    if ( nn_base_addr ) then nn_base_addr:delete() end 
  end
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:field_width()
  return H.extract_field(self, "field_width", "number")
end

function lVector:file_name(chunk_num)
  local f1, f2
  if ( chunk_num) then 
    f1 = cVector.file_name(self._base_vec, chunk_num)
  else
    f1 = cVector.file_name(self._base_vec)
  end
  if ( self._nn_vec ) then 
    if ( chunk_num) then 
      f2 = cVector.file_name(self._nn_vec, chunk_num)
    else
      f2 = cVector.file_name(self._nn_vec)
    end
  end
  return f1, f2
end

function lVector:fldtype()
  return H.extract_field(self, "fldtype", "string")
end

function lVector:flush_all()
  return H.on_both(self, cVector.flush_all)
end

function lVector:flush_chunk(chunk_num)
  return H.on_both(self, cVector.flush_chunk, chunk_num)
end

function lVector:get1(idx)
  local s1, s2
  s1 = assert(cVector.get1(self._base_vec, idx))
  if ( self:fldtype() == "SC" ) then 
    assert(type(s1) == "CMEM")
  else
    assert(type(s1) == "Scalar")
 end
  if ( self._nn_vec ) then 
    s2 = assert(cVector.get1(self._nn_vec, idx))
    assert(type(s2) == "Scalar")
    assert(s2:fldtype() == "B1")
  end
  return s1, s2
end

function lVector:get_chunk(chunk_num)
  assert(H.is_multiple_of_chunk_size(self:num_elements()))
  local base_addr, base_len
  local nn_addr,   nn_len  

  assert(type(chunk_num) == "number", "chunk_num is mandatory argument")
  assert(chunk_num >= 0)

  local last_chunk_num = -1 -- for 0 elements case
  if ( self:num_elements() == 0 ) then 
    last_chunk_num = self:num_elements()/cVector.chunk_size()
  end
  if ( chunk_num < last_chunk_num ) then
    assert(self:is_memo() == false, "Cannot serve earlier chunks")
  end
  if ( chunk_num >= last_chunk_num+2 ) then
    assert(self:is_memo() == false, "Cannot ask too far out")
  end
  if ( chunk_num == last_chunk_num+1 ) then
    -- Invoke generator
    assert(type(self._gen) == "function")
    local buf_size, base_data, nn_data = self._gen(chunk_num, self)
    assert(type(buf_size) == "number")
    assert(type(base_data) == "CMEM")
    assert(lVector.put_chunk(self._base_vec, base_data, buf_size))
    if ( self._nn_vec ) then 
      assert(lVector.put_chunk(self._nn_vec, nn_data, buf_size))
    end
    if ( buf_size < qconsts.chunk_size ) then self:eov() end
  end
  base_addr, base_len = cVector.get_chunk(self._base_vec, chunk_num)
  chk_chunk_addr(base_addr, base_len)

  -- for conjoined vectors
  if self.siblings then
    for k, v in pairs(self.siblings) do
      assert(type(v) == "lVector")
      assert(v:get_chunk(chunk_num))
    end
  end

  if ( qconsts.debug ) then self:check() end
  return base_len, base_addr,  nn_addr
end

function lVector:get_name()
  return H.extract_field(self, "name", "string")
end

-- not from Lua. Use cVector:init_globals()
--
function lVector:is_dead()
  return H.extract_field(self, "is_dead", "boolean")
end

function lVector:is_eov()
  return H.extract_field(self, "is_eov", "boolean")
end

function lVector:is_memo()
  return H.extract_field(self, "is_memo", "boolean")
end

function lVector:me()
  local M1, C1, M2, C2
  M1, C1 = cVector.me(self._base_vec)
  if ( self._nn_vec ) then 
    M2, C2 = cVector.me(self._nn_vec)
  end
  return M1, C1, M2, C2
end


function lVector:memo(is_memo)
  print("A: is_memo = ", is_memo)
  local is_memo = H.mk_boolean(is_memo, true)
  print("B: is_memo = ", is_memo)
  assert(H.on_both(self, cVector.memo, is_memo))
  return self
end

function lVector.new(args)
  local vector = setmetatable({}, lVector)
  vector._meta = {} -- for meta data stored in vector
  local is_rehydrate, is_single = H.determine_kind_of_new(args)

  if ( not is_rehydrate ) then 
    if arg.gen then vector._gen = arg.gen end 
    vector._base_vec = cVector.new(args)
    if ( args.has_nulls ) then 
      vector._nn_vec   = cVector.new( { qtype = "B1", width = 1 })
    end
  else -- materialized vector
    if ( args.has_nulls ) then
      if ( is_single ) then 
        vector._base_vec = assert(cVector.rehydrate_single(args[1]))
        vector._nn_vec = assert(cVector.rehydrate_single(args[2]))
      else
        vector._base_vec = assert(cVector.rehydrate_multi(args[1]))
        vector._nn_vec = assert(cVector.rehydrate_multi(args[2]))
      end
    else
      if ( is_single ) then 
        vector._base_vec = assert(cVector.rehydrate_single(args))
      else
        vector._base_vec = assert(cVector.rehydrate_multi(args))
      end
    end
  end
  --=============================================
  vector.siblings = {} -- no conjoined vectors
  return vector
end

function lVector:num_chunks()
  return H.extract_field(self, "num_chunks", "number")
end

-- Earlier, we would return nil if eov == false, have changed that
function lVector:num_elements()
  return H.extract_field(self, "num_elements", "number")
end

function lVector:persist(is_persist)
  local is_persist = H.mk_boolean(is_persist, true)
  assert(H.on_both(self, cVector.persist, is_persist))
  if ( qconsts.debug ) then self:check() end
  return self
end

-- not from Lua function lVector:print_timers()

function lVector:put1(s, nn_s)
  if ( self:fldtype() == "SC" ) then 
    assert( type(s) == "CMEM" )
  else
    assert( type(s) == "Scalar" ) 
  end
  assert(cVector.put1(self._base_vec, s))
  if ( self._nn_vec ) then 
    assert(type(nn_s) == "Scalar")
    assert(nn_s:fldtype() == "B1")
    assert(cVector.put1(self._nn_vec, nn_s))
  end
  if ( qconsts.debug ) then self:check() end
end
--
-- not from Lua function lVector:reset_timers()
-- TODO P4. Signature of put_chunk() should have matched get_chunk()
-- But that would involve a lot of changes. To be done sometime
function lVector:put_chunk(base_addr, nn_addr, len)
  if ( len == 0 )  then -- no more data
    return H.on_both(self, cVector.eov)
  end
  --====================
  -- TODO P4 Use on_both for the following..
  assert(type(base_addr) == "CMEM")
  assert(type(len) == "number")
  assert(cVector.put_chunk(self._base_vec, base_addr, len))
  if ( self._nn_vec ) then
    assert(type(nn_addr) == "CMEM")
    status = cVector.put_chunk(self._nn_vec, nn_addr, len)
    assert(status)
  end
  if ( qconsts.debug ) then self:check() end
end

-- not from Lua function lVector:same_state()
function lVector:set_name(vname)
  -- the name of an lVector is the name of its base Vector
  if ( type(vname) == nil ) then vname = "" end 
  assert(type(vname) == "string")
  assert(cVector.set_name(self._base_vec, vname))
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:start_read()
  assert(self:is_eov())
  local nn_addr, nn_len
  local base_addr, base_len = cVector.get(self._base_vec, 0, 0)
  assert(H.chk_addr_len(base_addr, base_len))
  if ( self._nn_vec ) then
    nn_addr, nn_len = cVector.get(self._nn_vec, 0, 0)
    assert(H.chk_addr_len(nn_addr, nn_len, base_len))
    assert(nn_len == base_len)
  end
  if ( qconsts.debug ) then self:check() end
  return base_len, base_addr, nn_addr
end


function lVector:start_write()
  local X, nX = cVector.start_write(self._base_vec)
  assert(type(X) == "CMEM")
  assert(type(nX) == "number")
  assert(nX > 0)
  if ( self._nn_vec ) then
    nn_X, nn_nX = assert(cVector.start_write(self._nn_vec))
    assert(type(nn_X) == "CMEM")
    assert(type(nn_nX) == "number")
    assert(nn_nX == nX)
  end
  if ( qconsts.debug ) then self:check() end
  return nX, X, nn_X
end


function lVector:unget_chunk(chunk_num)
  local s1, s2
  s1 = assert(cVector.unget_chunk(self._base_vec, chunk_num))
  if ( self._nn_vec ) then 
    s2 = assert(cVector.unget_chunk(self._nn_vec, chunk_num))
  end
  return s1, s2
end


--=== These are without any help from C 

function lVector:drop_nulls() 
  assert(self:is_eov())
  assert(cVector.delete(self._nn_vec))
  self._nn_vec = nil
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:get_meta(k)
  if ( qconsts.debug ) then self:check() end
  assert(k)
  assert(type(k) == "string")
  return self._meta[k]
end

function lVector:has_nulls()
  if ( self._nn_vec ) then return true else return false end
end

function lVector:make_nulls(bvec)
  assert(self:is_eov())
  assert(self._nn_vec == nil) 
  assert(type(bvec) == "lVector")
  assert(bvec:fldtype() == "B1")
  assert(cVector.same_state(self._base_vec, bvec))
  assert(bvec:has_nulls() == false)
  self._nn_vec = bvec._base_vec
  if ( qconsts.debug ) then self:check() end
  return self
end
  

function lVector:meta()
  -- TODO THINK
  -- with lua interpreter, load() is not supported with strings so using loadstring() 
  -- earlier with luajit interpreter, load() supported strings 
  local base_meta = loadstring(cVector.meta(self._base_vec))()
  local nn_meta = nil
  if ( self._nn_vec ) then 
    nn_meta = loadstring(cVector.meta(self._nn_vec))()
  end
  if ( qconsts.debug ) then self:check() end
  return { base = base_meta, nn = nn_meta, aux = self._meta}
end

function lVector:shutdown()
  if ( qconsts.debug ) then self:check() end
  local x = assert(cVector.shutdown(self._vec))
  return x 
end

function lVector:set_meta(k, v)
  if ( qconsts.debug ) then self:check() end
  assert(k)
  if ( not self._meta ) then self._meta = {} end 
  -- to destroy a value associated with a key
  if ( type(v) == nil ) then self._meta[k] = nil; return end
  -- TODO P3 What are valid types for v ?
  if ( string.sub(k, 1, 2) ~= "__" ) then 
    -- this is NOT a reserved word
    self._meta[k] = v
    return true
  end
  -- now deal with reserved keywords
  if ( ( k == "__max" ) or ( k == "__min" ) or ( k == "__sum" ) ) then
    -- TODO P3: Put more asserts on types of elements in table
    assert(type(v) == "table")
    if ( ( k == "__max" ) or ( k == "__min" ) ) then 
      assert(#v == 3) 
    end
    if ( k == "__sum" ) then
      assert(#v == 2) 
    end
  elseif ( ( k == "__meaning" ) or  ( k == "__name" ) ) then 
    assert(v and (type(v) == "string") and (#v > 0 ))
  elseif ( k == "__dictionary" ) then
    assert(v and (type(v) == "lDictionary") )
  else
    assert(nil)
  end
end

function lVector:set_sibling(x)
  assert(type(x) == "lVector")
  local exists = false
  for k, v in ipairs(self.siblings) do
    if ( x == v ) then
      exists = true
    end
  end
  if ( not exists ) then
    self.siblings[#self.siblings+1] = x
  end
  return self
end

function lVector:unget_chunk(chunk_num)
  assert(on_both(self, cVector.unget_chunk, chunk_num))
  return self
end
--====================
-- This are aliases to maintain backward compatibility
function lVector:chunk(chunk_num)
  return lVector:get_chunk(chunk_num)
end

function lVector:length()
  return lVector:num_elements()
end

function lVector:get_all()
  return lVector:get_read()
end

function lVector:qtype()
  return lVector:fldtype()
end

function lVector:width()
  return lVector:field_width()
end
--====================

return lVector
