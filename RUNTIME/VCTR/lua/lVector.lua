-- If not, any other string will work but do not use __ as a prefix
local ffi               = require 'ffi'
local qconsts		= require 'Q/UTILS/lua/qconsts'
local cutils            = require 'libcutils'
local cmem		= require 'libcmem'
local Scalar		= require 'libsclr'
local cVector		= require 'libvctr'
local to_scalar		= require 'Q/UTILS/lua/to_scalar'
local register_type	= require 'Q/UTILS/lua/q_types'
local H                 = require 'Q/RUNTIME/VCTR/lua/helpers'
local qc                = require 'Q/UTILS/lua/qcore'
qc.q_cdef( "RUNTIME/VCTR/inc/vctr_struct.h",{ "UTILS/inc/" })
-- TO DELETE TODO qc.q_cdef("UTILS/inc/qmem_struct.h")
local qmem              = require 'Q/UTILS/lua/qmem'
local chunk_size        = qmem.chunk_size
local g_S               = qmem.cdata
--====================================
local lVector = {}
lVector.__index = lVector

setmetatable(lVector, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(lVector, "lVector")

function lVector:check()
  -- cannot use function on_both here because check called from within
  assert(cVector.check(self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.check(self._nn_vec))
  end 
  return true
end

function lVector:num_chunks()
  return H.extract_field(self._base_vec, self._nn_vec, "num_chunks", "number")
end

-- Earlier, we would return nil if eov == false, have changed that
function lVector:num_elements()
  return H.extract_field(self._base_vec, self._nn_vec, "num_elements", "number")
end

function lVector:get_name()
  return H.extract_field(self._base_vec, self._nn_vec, "name", "string")
end

--
function lVector:is_dead()
  return H.extract_field(self._base_vec, self._nn_vec, "is_dead", "boolean")
end

function lVector:is_eov()
  return H.extract_field(self._base_vec, self._nn_vec, "is_eov", "boolean")
end

function lVector:is_memo()
  return H.extract_field(self._base_vec, self._nn_vec, "is_memo", "boolean")
end

function lVector:fldtype()
  return H.extract_field(self._base_vec, self._nn_vec, "fldtype", "string")
end
function lVector:field_width()
  return H.extract_field(self._base_vec, self._nn_vec, "field_width", "number")
end

function lVector:length()
  -- TODO P2 Why does following not work 
  -- return lVector:num_elements()
  return H.extract_field(self._base_vec, self._nn_vec, "num_elements", "number")
end

function lVector:qtype()
  return H.extract_field(self._base_vec, self._nn_vec, "fldtype", "string")
end

function lVector:width()
  return H.extract_field(self._base_vec, self._nn_vec, "field_width", "number")
end
--====================
function lVector:delete()
  local status = cVector.delete(self._base_vec) 
  if ( not status ) then print("Likely you are deleting dead vector") end
  if ( self._nn_vec ) then 
    status = cVector.delete(self._nn_vec) 
    if ( not status ) then print("Likely you are deleting dead vector") end
  end
  return true
end

-- Mainly used for testing. Not really needed by Q programmer
function lVector:un_backup_chunk(chunk_num)
  assert(cVector.un_backup_chunk(g_S, self._base_vec, chunk_num))
  if ( self._nn_vec ) then 
    assert(cVector.un_backup_chunk(g_S, self._nn_vec, chunk_num)) 
  end 
  return self
end

-- Mainly used for testing. Not really needed by Q programmer
function lVector:un_backup_chunks()
  assert(cVector.un_backup_chunk(g_S, self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.un_backup_chunk(g_S, self._nn_vec)) 
  end 
  return self
end

-- Mainly used for testing. Not really needed by Q programmer
function lVector:backup_chunk(chunk_num)
  assert(cVector.backup_chunk(g_S, self._base_vec, chunk_num))
  if ( self._nn_vec ) then 
    assert(cVector.backup_chunk(g_S, self._nn_vec, chunk_num)) 
  end 
  return self
end

-- Mainly used for testing. Not really needed by Q programmer
function lVector:backup_chunks()
  assert(cVector.backup_chunk(g_S, self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.backup_chunk(g_S, self._nn_vec)) 
  end 
  return self
end

-- Mainly used for testing. Not really needed by Q programmer
function lVector:un_load_chunk(chunk_num)
  assert(cVector.un_load_chunk(g_S, self._base_vec, chunk_num))
  if ( self._nn_vec ) then 
    assert(cVector.un_load_chunk(g_S, self._nn_vec, chunk_num)) 
  end 
  return self
end

-- Mainly used for testing. Not really needed by Q programmer
function lVector:un_load_chunks()
  assert(cVector.un_load_chunk(g_S, self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.un_load_chunk(g_S, self._nn_vec)) 
  end 
  return self
end

-- Mainly used for testing. Not really needed by Q programmer
function lVector:load_chunk(chunk_num)
  assert(cVector.load_chunk(g_S, self._base_vec, chunk_num))
  if ( self._nn_vec ) then 
    assert(cVector.load_chunk(g_S, self._nn_vec, chunk_num)) 
  end 
  return self
end

-- Mainly used for testing. Not really needed by Q programmer
function lVector:load_chunks()
  assert(cVector.load_chunk(g_S, self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.load_chunk(g_S, self._nn_vec)) 
  end 
  return self
end

-- used for testing. Not really needed by Q programmer
function lVector:backup_vec()
  assert(cVector.backup_vec(g_S, self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.backup_vec(g_S, self._nn_vec)) 
  end 
  return self
end

-- Mainly used for testing. Not really needed by Q programmer
function lVector:un_backup_vec()
  assert(cVector.un_backup_vec(g_S, self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.un_backup_vec(g_S, self._nn_vec)) 
  end 
  return self
end

-- Get read access to the entire vector in a single liner address space
function lVector:start_read()
  local nn_X, nn_nX 
  local X, nX = cVector.start_read(g_S, self._base_vec)
  assert(type(X) == "CMEM")
  assert(type(nX) == "number")
  assert(nX > 0)
  if ( self._nn_vec ) then
    nn_X, nn_nX = cVector.start_read(g_S, self._nn_vec)
    assert(type(nn_X) == "CMEM")
    assert(type(nn_nX) == "number")
    assert(nn_nX > 0)
    assert(nX == nn_nX)
  end
  if ( qconsts.debug ) then self:check() end
  return nX, X, nn_X
end

-- Relinquish read access to the entire vector 
function lVector:end_read()
  assert(cVector.end_read(g_S, self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.end_read(g_S, self._nn_vec)) 
  end 
  return self
end

-- Get write access to the entire vector in a single liner address space
function lVector:start_write()
  local nn_X, nn_nX 
  local X, nX = cVector.start_write(g_S, self._base_vec)
  assert(type(X) == "CMEM")
  assert(type(nX) == "number")
  assert(nX > 0)
  if ( self._nn_vec ) then
    nn_X, nn_nX = assert(cVector.start_write(g_S, self._nn_vec))
    assert(type(nn_X) == "CMEM")
    assert(type(nn_nX) == "number")
    assert(nn_nX == nX)
  end
  if ( qconsts.debug ) then self:check() end
  return nX, X, nn_X
end

-- Relinquish write access to the entire vector 
function lVector:end_write()
  assert(cVector.end_write(g_S, self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.end_write(g_S, self._nn_vec)) 
  end 
  return self
end

-- Indicates that no more data will be supplied to this vector
function lVector:eov()
  assert(H.on_both(self, cVector.eov))
-- destroy generator (if any) and thereby 
-- (1) release resources held by it 
-- (2) no more data can be added to Vector
  self._gen = nil 
  if ( self:num_elements() == 0 ) then return nil end
  return self
end

-- will delete the vector *ONLY* if marked as is_killable; else, NOP
function lVector:kill()
  cVector.kill(g_S, self._base_vec)
  if ( self._nn_vec ) then cVector.kill(g_S, self._nn_vec) end 
  return true 
end

-- evaluates the vector using a provided generator function
-- when done, is_eov() will be true for this vector
-- if is_eov() at time of call, nothing is done 
function lVector:eval()
  if ( self:is_eov() ) then return self end 
  assert(H.is_multiple(self:num_elements(), chunk_size))
  local chunk_num = self:num_elements() / chunk_size
  local base_len, base_addr, nn_addr 
  repeat
    base_len, base_addr, nn_addr = self:get_chunk(chunk_num)
    -- this unget needed because get_chunk increments num readers 
    -- and the eval doesn't actually get the chunk for itself
    cVector.unget_chunk(self._base_vec, chunk_num)
    if ( self._nn_vec ) then 
      cVector.unget_chunk(self._nn_vec, chunk_num) 
    end
    chunk_num = chunk_num + 1 
  until ( base_len ~= chunk_size ) 
  assert(self:is_eov())
  -- cannot have Vector with 0 elements
  if ( self:num_elements() == 0 ) then  return nil  end
  -- 07/2019
  -- This delete() is an important change from previous implemenation.
  -- The generator that gave us the data would have allocated a CMEM
  -- Now that the Vector has been fully created, that is not needed
  -- Hence ,its okay to go ahead and delete the memory within the CMEM
  -- Note that the deletion of the CMEM itself is up to Lua
  if ( type(self._gen) == "function" ) then 
    if (    base_addr ) then    base_addr:delete() end 
    if ( nn_base_addr ) then nn_base_addr:delete() end 
    self._gen = nil -- generation all done => no generator needed
  end
  if ( qconsts.debug ) then self:check() end
  return self
end

-- If chunk_num not defined, return name of vector file 
-- If chunk_num IS  defined, return name of file in which chunk data is 
-- Note that these files may not exist. If you want them to exist, 
-- then you must call vec_backup()
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


function lVector:free()
  local status = cVector.free(g_S, self._base_vec) 
  if ( not status ) then print("Likely you are freeing dead vector") end
  if ( self._nn_vec ) then 
    status = cVector.free(g_S, self._nn_vec) 
    if ( not status ) then print("Likely you are freeing dead vector") end
  end
  return true
end

-- gets the value of the element whose index is specified by idx
-- if you ask for more than what has been generated, error 
function lVector:get1(idx)
  -- notice that get1 will not invoke generator
  local s1, s2
  s1 = assert(cVector.get1(g_S, self._base_vec, idx))
  if ( self:fldtype() == "SC" ) then 
    assert(type(s1) == "CMEM")
  else
    assert(type(s1) == "Scalar")
 end
  if ( self._nn_vec ) then 
    s2 = assert(cVector.get1(g_S, self._nn_vec, idx))
    assert(type(s2) == "Scalar")
    assert(s2:fldtype() == "B1")
  end
  return s1, s2
end

function lVector:get_chunk(chunk_num)
  local base_addr, base_len
  local nn_addr,   nn_len  
  local num_elements = self:num_elements()

  --=======
  -- If you don't specify a chunk number, then we will 
  -- 1) assert that the number of elements is a multiple of chunk size
  -- 2) assume you want the immeidately next chunk. So, if the vector had 10
  -- elements and the chunk size was 5, then chunk num would be 2
  if ( type(chunk_num) == "nil" ) then 
    assert(H.is_multiple(num_elements, chunk_size))
    chunk_num = num_elements / chunk_size
    assert(math.floor(chunk_num) == math.ceil(chunk_num))
  end
  assert(type(chunk_num) == "number"); assert(chunk_num >= 0)
  --=======
  -- If we have created n chunks, then you can ask for chunk n+1 but not
  -- for n+2, n+3, ...
  if ( chunk_num * chunk_size > num_elements ) then 
    -- print("asking for data too far away from where we are")
    return 0
  end
  --=======
  -- if Vector has NOT been memo-ized, then you can only get recent chunk
  if ( num_elements > 0 ) then 
    local most_recent_chunk = math.floor((num_elements-1)/ chunk_size)
    if ( ( self:is_memo() == false ) and 
         ( chunk_num < most_recent_chunk ) ) then 
      error("Cannot serve earlier chunks")
    end
  end
  --=======
  -- Assume num_elements = 6 ,chunk_size = 4, chunk_num = 1
  -- In that case, we do NOT invoke the generator
  if ( chunk_num * chunk_size == num_elements ) then 
    -- we have to get some more elements 
    assert(not self:is_eov()) 
    -- Invoke generator
    if (type(self._gen) == "function") then 
      local buf_size, base_data, nn_data = self._gen(chunk_num)
      -- NOTE: if buf_size == 0, do not look at base_data/nn_data
      assert(type(buf_size) == "number")
      if ( buf_size > 0 ) then 
        assert(type(base_data) == "CMEM")
        assert(cVector.put_chunk(g_S, self._base_vec, base_data, buf_size))
        if ( self._nn_vec ) then 
          assert(type(nn_data) == "CMEM")
          assert(lVector.put_chunk(g_S, self._nn_vec, nn_data, buf_size))
        end
      else
        self:eov(); return 0 
      end
      if ( buf_size < chunk_size ) then self:eov() end
    else
      return 0
    end
  end
  --== Now you should be able to get the data you want
  base_addr, base_len = cVector.get_chunk(g_S, self._base_vec, chunk_num)

  H.chk_addr_len(base_addr, base_len)
  if ( self._nn_vec ) then 
    nn_addr, nn_len = cVector.get_chunk(g_S, self._nn_vec, chunk_num)
    H.chk_addr_ler(nn_addr, nn_len, base_len)
  end
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

function lVector:unget_chunk(chunk_num)
  assert(cVector.unget_chunk(g_S, self._base_vec, chunk_num))
  if ( self._nn_vec ) then 
    assert(cVector.unget_chunk(g_S, self._nn_vec, chunk_num))
  end
  return self
end

-- Provides meta-data at a low-level by returning
-- struct for the vector an array of structs for chunks
function lVector:me()
  local M1, C1, M2, C2
  M1, C1 = cVector.me(self._base_vec)
  assert(type(M1) == "userdata")
  assert(type(C1) == "table")
  -- Commented to handle case of just-born Vectors. assert(#C1 > 0)
  for _, v in ipairs(C1) do 
    assert(type(v) == "userdata")
  end
  if ( self._nn_vec ) then 
    M2, C2 = cVector.me(self._nn_vec)
    assert(type(M2) == "userdata")
    assert(type(C2) == "table")
    assert(#C2 > 0)
    for _, v in ipairs(C2) do 
      assert(type(v) == "userdata")
    end
  end
  return M1, C1, M2, C2
end

function lVector:clone()
  local v2, nn_v2
  local v1 = self._base_vec
  assert(v1:is_eov())
  cVector.master(g_S, v1)
  local x, y = cVector.reincarnate(g_S, v1)
  assert(x, y)
  assert(type(x) == "string")
  local y = loadstring(x)()
  assert(type(y) == "table")
  local v2 = lVector.new(y)
  assert(type(v2) == "lVector")
  if ( self._nn_vec ) then
    error("TODO P1 Not implemented as yet")
  end
  return v2, nn_v2
end

function lVector:memo(is_memo)
  local is_memo = H.mk_boolean(is_memo, true)
  assert(H.on_both(self, cVector.memo, is_memo))
  return self
end

function lVector.new(args)
  local vector = setmetatable({}, lVector)
  vector._meta = {} -- for meta data stored in vector
  local is_rehydrate = H.determine_kind_of_new(args)

  if ( not is_rehydrate ) then 
    if args.gen then 
      if ( args.gen ) then 
        assert(type(args.gen) == "function") 
        vector._gen = args.gen 
      end
    end 
    assert(type(args.qtype) == "string") 
    --=======================
    if ( args.qtype ~= "SC" ) then 
      args.width = qconsts.qtypes[args.qtype].width
    end
    assert(type(args.width) == "number") 
    --=======================
    vector._base_vec = assert(cVector.new(args))
    if ( qconsts.debug ) then 
      assert(cVector.check(vector._base_vec)) 
    end 
    if ( args.has_nulls ) then 
      vector._nn_vec   = cVector.new( { qtype = "B1", width = 1 })
      if ( qconsts.debug ) then 
        assert(cVector.check(vector._nn_vec)) 
      end 
    end
    --=======================
    local is_memo
    if ( args.is_memo ) then
      is_memo = args.is_memo
    else
      is_memo = qconsts.is_memo
    end 
    cVector.memo(vector._base_vec, is_memo)
    if ( vector._nn_vec ) then 
      cVector.memo(vector._nn_vec, is_memo)
    end
    --=======================
  else -- materialized vector
    vector._base_vec = assert(cVector.rehydrate(g_S, args))
    if ( args.has_nulls ) then
      error("NOT IMPLEMENTED") -- TODO P1
      vector._nn_vec   = assert(cVector.rehydrate(args[2]))
    end
  end
  --=============================================
  vector.siblings = {} -- no conjoined vectors
  return vector
end

-- sometimes we may want to set generator a bit after we create the Vector
function lVector:set_gen(gen)
  assert(self:length() == 0)
  assert(type(gen) == "function")
  self._gen = gen
end


function lVector:persist(is_persist)
  local is_persist = H.mk_boolean(is_persist, true)
  assert(H.on_both(self, cVector.persist, is_persist))
  if ( qconsts.debug ) then self:check() end
  return self
end


-- Puts one element at a time into Vector
-- eov cannot be true for the Vector
function lVector:put1(s, nn_s)
  assert ( not self._gen ) -- if you have a generator, cannot apply put*
  if ( self:fldtype() == "SC" ) then 
    assert( type(s) == "CMEM" )
  else
    assert( type(s) == "Scalar" ) 
  end
  assert(cVector.put1(g_S, self._base_vec, s))
  if ( self._nn_vec ) then 
    assert(type(nn_s) == "Scalar")
    assert(nn_s:fldtype() == "B1")
    assert(cVector.put1(g_S, self._nn_vec, nn_s))
  end
  if ( qconsts.debug ) then self:check() end
  return true
end
--
-- TODO P4. Signature of put_chunk() should have matched get_chunk()
-- But that would involve a lot of changes. To be done sometime
function lVector:put_chunk(base_addr, nn_addr, len)
  --[[ This is an interesting point. I had initially had a check as follows
  -- assert ( not self._gen ) -- if you have a generator, cannot apply put*
  -- But I realized that it is too aggressive. To see why this is the case,
  -- look at any expander that returns 2 Vectors. When the generator of
  -- Vector 1 is called, we have to call put_chunk() on Vector 2.  When the 
  -- generator of Vector 2 is called, we have to put_chunk() on Vector 1.
  -- So both Vectors have generators and both must allow put chunk to be
  -- called on them
  --]]
  if ( ( type(len) == "number") and ( len == 0 ) )  then -- no more data
    return H.on_both(self, cVector.eov)
  end
  if ( type(len) == "nil" ) then
    len = cVector.chunk_size()
  end
  assert(type(len) == "number")
  --====================
  -- TODO P4 Use on_both for the following..
  assert(type(base_addr) == "CMEM")
  assert(cVector.put_chunk(self._base_vec, base_addr, len))
  if ( self._nn_vec ) then
    assert(type(nn_addr) == "CMEM")
    status = cVector.put_chunk(self._nn_vec, nn_addr, len)
    assert(status)
  end
  if ( len and ( len < cVector.chunk_size() ) ) then 
    assert(cVector.eov(self._base_vec))
    if ( self._nn_vec ) then
      assert(cVector.eov(self._nn_vec))
    end
  end
    
  if ( qconsts.debug ) then self:check() end
  return true
end

function lVector:set_name(vname)
  -- the name of an lVector is the name of its base Vector
  if ( type(vname) == nil ) then vname = "" end 
  assert(type(vname) == "string")
  assert(cVector.set_name(self._base_vec, vname))
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:drop_nulls() 
  if (not self._nn_vec) then return self end 
  assert(self:is_eov())
  assert(cVector.delete(self._nn_vec))
  self._nn_vec = nil
  if ( qconsts.debug ) then self:check() end
  return self
end

-- No help from C needed for this function
function lVector:get_meta(k)
  if ( qconsts.debug ) then self:check() end
  assert(k)
  assert(type(k) == "string")
  return self._meta[k]
end

-- No help from C needed for this function
function lVector:has_nulls()
  if ( self._nn_vec ) then return true else return false end
end

-- Make bvec the nn vector for this Vector 
-- current vector must be "memoized" and in eov state
function lVector:make_nulls(bvec)
  assert(self:is_eov())
  assert(self:is_memo())
  assert(self._nn_vec == nil) 

  assert(type(bvec) == "lVector")
  assert(bvec:fldtype() == "B1")
  assert(bvec:has_nulls() == false)

  assert(cVector.same_state(self._base_vec, bvec))
  self._nn_vec = bvec._base_vec
  if ( qconsts.debug ) then self:check() end
  return self
end
  

function lVector:meta()
  -- TODO THINK
  -- with lua interpreter, load() is not supported with strings so using loadstring() 
  -- earlier with luajit interpreter, load() supported strings 
  local x = cVector.meta(self._base_vec)
  assert(type(x) == "string")
  local y = assert(loadstring(x))
  assert(type(y) == "function")
  local base_meta = y()
  local nn_meta = nil
  if ( self._nn_vec ) then 
    nn_meta = loadstring(cVector.meta(self._nn_vec))()
  end
  if ( qconsts.debug ) then self:check() end
  return { base = base_meta, nn = nn_meta, aux = self._meta}
end

function lVector:shutdown()
  if ( qconsts.debug ) then self:check() end
  local reincarnate_str = cVector.shutdown(g_S, self._base_vec)
  if ( not reincarnate_str ) then 
    print("Unable to shutdown"); return nil 
  end 
  -- TODO P1 What about nn_vec?
  return reincarnate_str
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
    local v = assert(to_scalar(v, self:qtype()))
    self._meta[k] = v
  else
    assert(nil, "TO BE IMPLEMENTED")
  end
end

-- add x as one of the siblings of current Vector
-- can do so only when all Vectors involved are in nascent state
function lVector:set_sibling(x)
  assert(type(x) == "lVector")
  assert(x:num_elements() == 0)
  assert(self:num_elements() == 0)
  -- make sure that x is not already a sibling
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

-- for backward compatibility
function lVector:get_all()
  return lVector:get_read()
end

return lVector
