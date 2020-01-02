-- If not, any other string will work but do not use __ as a prefix
local ffi               = require 'ffi'
local qconsts		= require 'Q/UTILS/lua/q_consts'
local cutils            = require 'libcutils'
local cmem		= require 'libcmem'
local Scalar		= require 'libsclr'
local Vector		= require 'libvec'
local register_type	= require 'Q/UTILS/lua/q_types'
local is_base_qtype	= require 'Q/UTILS/lua/is_base_qtype'
local chk_chunk_return	= require 'Q/UTILS/lua/chk_chunk'
local qc		= require 'Q/UTILS/lua/q_core'
--====================================
local lVector = {}
lVector.__index = lVector

setmetatable(lVector, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(lVector, "lVector")

function on_both(
  base_vec,
  nn_vec,
  fn_to_apply
  )
  assert(fn_to_apply(base_vec))
  if ( nn_vec ) then assert(fn_to_apply(nn_vec)) end 
  if ( qconsts.debug ) then self:check() end
  return true
end

local function chk_addr_len(x, len, chk_len)
  assert(type(x) == "CMEM")
  assert(type(len) == "number")
  assert(len > 0)
  if ( chk_len ) then
    assert(len == chk_len)
  end
end

function extract_field(key, valtype)
  assert(type(key) == "string")
  assert(#key > 0)
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  local base_val, nn_val
  --=============================
  if ( valtype == "number" ) then 
    if ( casted_base_vec[0][key]) then 
      base_val = tonumber(casted_base_vec[0][key])
    end
  elseif ( valtype == "string" ) then 
    base_val = ffi.string(casted_base_vec[0][key])
  elseif ( valtype == "boolean" ) then 
    base_val = casted_base_vec[0][key]
  else
    error("bad valtype")
  end
  --=============================
  if ( self._nn_vec ) then 
    local casted_nn_vec   = ffi.cast("VEC_REC_TYPE *", self._nn_vec)
    if ( valtype == "number" ) then 
      nn_val = tonumber(casted_base_vec[0][key])
    elseif ( valtype == "string" ) then 
      nn_val = ffi.string(casted_base_vec[0][key])
    elseif ( valtype == "boolean" ) then 
      nn_val = casted_base_vec[0][key]
    else
      error("bad valtype")
    end
  end
  return base_val, nn_val
end

function lVector:backup()
  return on_both(self._base_vec, self._nn_vec, Vector.backup)
end

function lVector:check()
  return on_both(self._base_vec, self._nn_vec, Vector.check)
end

-- not from Lua. Use cVector:check_chunks()
-- directly from struct: lVector:chunk_size_in_bytes()
function lVector:chunk_size_in_bytes()
  if ( qconsts.debug ) then self:check() end
  local cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return cbv[0].chunk_size_in_bytes
end

--
function lVector:delete()
  return on_both(self._base_vec, self._nn_vec, Vector.delete)
end

function lVector:delete_chunk_file(chunk_num)
  assert(Vector.delete_chunk_file(self._base_vec, chunk_num))
  if ( self._nn_vec ) then 
    assert(Vector.delete_chunk_file(self._nn_vec, chunk_num))
  end
  return true
end

function lVector:delete_master_file()
  return on_both(self._base_vec, self._nn_vec, Vector.delete_master_file)
end

function lVector:end_read()
  return on_both(self._base_vec, self._nn_vec, Vector.end_read)
end

function lVector:end_write()
  return on_both(self._base_vec, self._nn_vec, Vector.end_write)
end

function lVector:eov()
  assert(on_both(self._base_vec, self._nn_vec, Vector.eov))
-- destroy generator (if any) and thereby 
-- (1) release resources held by it 
-- (2) no more data can be added to Vector
  self._gen = nil 
  if ( self:num_elements() == 0 ) then return nil end
  return self
end

function lVector:field_width()
  return extract_field("field_width", "number")
end

function lVector:file_name()
  return extract_field("file_name", "string")
end

-- directly from struct: lVector:fldtype()
function lVector:fldtype()
  return extract_field("fldtype", "string")
end

function lVector:flush_all()
  return on_both(self._base_vec, self._nn_vec, Vector.flush_all)
end

function lVector:flush_chunk(chunk_num)
  assert(Vector.flush_chunk(self._base_vec, chunk_num))
  if ( self._nn_vec ) then 
    assert(Vector.flush_chunk(self._nn_vec, chunk_num))
  end
  return true
end

function lVector:get1(idx)
  local s1, s2
  s1 = assert(Vector.get1(self._base_vec, idx))
  if ( self:fldtype() == "SC" ) then 
    assert(type(s1) == "CMEM")
  else
    assert(type(s1) == "Scalar")
 end
  if ( self._nn_vec ) then 
    s2 = assert(Vector.get1(self._nn_vec, idx))
    assert(type(s2) == "Scalar")
    assert(s2:fldtype() == "B1")
  end
  return s1, s2
end

-- directly from struct lVector:get_name()
function lVector:get_name()
  -- the name of an lVector is the name of its base Vector
  if ( qconsts.debug ) then self:check() end
  cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return ffi.string(cbv[0].name)
end

-- not from Lua. Use cVector:init_globals()
--
function lVector:is_dead()
  return extract_field("is_dead", "boolean")
end

function lVector:is_eov()
  return extract_field("is_eov", "boolean")
end

function lVector:is_memo()
  return extract_field("is_memo", "boolean")
end

function lVector:me()
  local M1, C1, M2, C2
  M1, C1 = Vector.me(self._base_vec)
  if ( self._nn_vec ) then 
    M2, C2 = Vector.me(self._nn_vec)
  end
  return M1, C1, M2, C2
end


function lVector:memo(is_memo)
  if ( is_memo == nil ) then 
    is_memo = true
  else
    assert(type(is_memo) == "boolean")
  end
  assert(on_both(self._base_vec, self._nn_vec, Vector.memo))
  return self
end

local function determine_kind_of_new(args)
  assert(type(arg) == "table", "Vector constructor requires table as arg")
  local is_rehydrate = false
  local is_single = true
  assert(type(args) == "table")
  if ( ( #args == 2 ) and 
       ( type(arg[1]) == "table" ) and ( type(arg[2]) == "table" ) ) then
    args.has_nulls = true
    assert(type(args[2] == "table"))
    for k, v in pairs(args) do 
      if ( ( k == 1 ) or ( k == 2 ) ) then 
        assert(type(v == "table"))
      else
        error("bad args")
      end
    end
  else
    if ( args.file_name ) then 
      is_rehydrate = true; is_single = true
    end
    if ( args.file_names ) then 
      is_rehydrate = true; is_single = false
    end
  end
   --=============================
  if ( is_rehydrate == false ) then 
    if ( args.has_nulls) then 
      assert(type(args.has_nulls) == "boolean")
    else -- get from qconsts, default usually false
      args.has_nulls = qconsts.has_nulls 
    end
   --=============================
    assert(qconsts.qtypes[args.qtype], "Invalid qtype provided")
    if ( args.qtype ~= "SC" ) then 
      args.width = qtypes.qtype[args.qtype].width
    end
   --=============================
  end
   --=============================
  return is_rehydrate, is_single
end

function lVector.new(arg)
  local vector = setmetatable({}, lVector)
  -- for meta data stored in vector
  vector._meta = {}
  is_rehydrate, is_single = determine_kind_of_new(args)

  if ( not is_rehydrate ) then 
    if arg.gen then vector._gen = arg.gen end 
    vector._base_vec = Vector.new(args)
    if ( args.has_nulls ) then 
      vector._nn_vec   = Vector.new( { qtype = "B1", width = 1 })
    end
  else -- materialized vector
    if ( args.has_nulls ) then
      if ( is_single ) then 
        vector._base_vec = assert(Vector.rehydrate_single(args[1]))
        vector._nn_vec = assert(Vector.rehydrate_single(args[2]))
      else
        vector._base_vec = assert(Vector.rehydrate_multi(args[1]))
        vector._nn_vec = assert(Vector.rehydrate_multi(args[2]))
      end
    else
      if ( is_single ) then 
        vector._base_vec = assert(Vector.rehydrate_single(args))
      else
        vector._base_vec = assert(Vector.rehydrate_multi(args))
      end
    end
  end
  --=============================================
  vector.siblings = {} -- no conjoined vectors
  return vector
end

function lVector:num_chunks()
  return extract_field("num_chunks", "number")
end

-- Earlier, we would return nil if eov == false, have changed that
-- directly from struct lVector:num_elements()
function lVector:num_elements()
  return extract_field("num_elements", "number")
end

function lVector:persist(is_persist)
  if ( is_persist == nil ) then 
    is_persist = true
  else
    assert(type(is_persist) == "boolean")
  end
  assert(on_both(self._base_vec, self._nn_vec, Vector.persist))
  if ( qconsts.debug ) then self:check() end
  return self
end

-- TODO put_chunk
-- TODO get_chunk

-- not from Lua function lVector:print_timers()
-- not from Lua function lVector:reset_timers()
-- not from Lua function lVector:same_state()

function lVector:put1(s, nn_s)
  if ( self:fldtype() == "SC" ) then 
    assert( type(s) == "CMEM" )
  else
    assert( type(s) == "Scalar" ) 
  end
  assert(Vector.put1(self._base_vec, s))
  if ( self._nn_vec ) then 
    assert(type(nn_s) == "Scalar")
    assert(nn_s:fldtype() == "B1")
    assert(Vector.put1(self._nn_vec, nn_s))
  end
  if ( qconsts.debug ) then self:check() end
end

function lVector:start_write()
  local X, nX = Vector.start_write(self._base_vec)
  assert(type(X) == "CMEM")
  assert(type(nX) == "number")
  assert(nX > 0)
  if ( self._nn_vec ) then
    nn_X, nn_nX = assert(Vector.start_write(self._nn_vec))
    assert(type(nn_X) == "CMEM")
    assert(type(nn_nX) == "number")
    assert(nn_nX == nX)
  end
  if ( qconsts.debug ) then self:check() end
  return nX, X, nn_X
end

function lVector:end_write()
  return on_both(self._base_vec, self._nn_vec, Vector.end_write)
end

-- TODO P4. Signature of put_chunk() should have matched chunk()
-- TODO P4. Also chunk() should have been called get_chunk()
-- But that would involve a lot of changes. To be done sometime
function lVector:put_chunk(base_addr, nn_addr, len)
  local status
  assert(type(len) == "number")
  assert(len >= 0)
  if ( len == 0 )  then -- no more data
    return on_both(self._base_vec, self._nn_vec, Vector.eov)
  end
  --====================
  assert(type(base_addr) == "CMEM")
  assert(Vector.put_chunk(self._base_vec, base_addr, len))
  if ( self._nn_vec ) then
    assert(type(nn_addr) == "CMEM")
    status = Vector.put_chunk(self._nn_vec, nn_addr, len)
    assert(status)
  end
  if ( qconsts.debug ) then self:check() end
end

function lVector:eval()
  if ( not self:is_eov() ) then
    local chunk_num = self:chunk_num() 
    local base_len, base_addr, nn_addr 
    repeat
      base_len, base_addr, nn_addr = self:chunk(chunk_num)
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
    if ( type(self.gen) == "function" ) then 
      if (    base_addr ) then    base_addr:delete() end 
      if ( nn_base_addr ) then nn_base_addr:delete() end 
    end
  end
  -- else, nothing do to since vector has been materialized
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:get_chunk(chunk_num)
  local base_addr, base_len
  local nn_addr,   nn_len  
  if ( self:num_elements() == 0 ) then return 0 end 

  assert(type(chunk_num) == "number", "chunk_num is mandatory argument")
  assert(chunk_num >= 0)

  local current_chunk_num = math.ceil(
    self:num_elements() / self:chunk_size())
  if ( chunk_num < current_chunk_num ) then
    assert(self:is_memo() == false, "Cannot serve earlier chunks")
  end
  if ( chunk_num > current_chunk_num+1 ) then
    assert(self:is_memo() == false, "Cannot ask too far out")
  end
  if ( chunk_num > current_chunk_num+1 ) then
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
  base_addr, base_len = Vector.get_chunk(self._base_vec, chunk_num)
  chk_chunk_addr(base_addr, base_len)

  -- for conjoined vectors
  if self.siblings then
    for k, v in pairs(self.siblings) do
      v:chunk(l_chunk_num)
    end
  end

  if ( qconsts.debug ) then self:check() end
  return base_len, base_addr,  nn_addr
end

function lVector:set_name(vname)
  -- the name of an lVector is the name of its base Vector
  if ( type(vname) == nil ) then vname = "" end 
  assert(type(vname) == "string")
  assert(Vector.set_name(self._base_vec, vname))
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:start_read()
  assert(self:is_eov())
  local nn_addr, nn_len
  local base_addr, base_len = Vector.get(self._base_vec, 0, 0)
  assert(chk_addr_len(base_addr, base_len))
  if ( self._nn_vec ) then
    nn_addr, nn_len = Vector.get(self._nn_vec, 0, 0)
    assert(chk_addr_len(nn_addr, nn_len, base_len))
    assert(nn_len == base_len)
  end
  if ( qconsts.debug ) then self:check() end
  return base_len, base_addr, nn_addr
end


function lVector:unget_chunk(chunk_num)
  local s1, s2
  s1 = assert(Vector.unget_chunk(self._base_vec, chunk_num))
  if ( self._nn_vec ) then 
    s2 = assert(Vector.unget_chunk(self._nn_vec, chunk_num))
  end
  return s1, s2
end


--=== These are without any help from C 

function lVector:drop_nulls() 
  assert(self:is_eov())
  assert(Vector.delete(self._nn_vec))
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
  assert(Vector.same_state(self._base_vec, bvec))
  assert(bvec:has_nulls() == false)
  self._nn_vec = bvec._base_vec
  if ( qconsts.debug ) then self:check() end
  return self
end
  

function lVector:meta()
  -- TODO THINK
  -- with lua interpreter, load() is not supported with strings so using loadstring() 
  -- earlier with luajit interpreter, load() supported strings 
  local base_meta = loadstring(Vector.meta(self._base_vec))()
  local nn_meta = nil
  if ( self._nn_vec ) then 
    nn_meta = loadstring(Vector.meta(self._nn_vec))()
  end
  if ( qconsts.debug ) then self:check() end
  return { base = base_meta, nn = nn_meta, aux = self._meta}
end

function lVector:shutdown()
  if ( qconsts.debug ) then self:check() end
  local x = assert(Vector.shutdown(self._vec))
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
