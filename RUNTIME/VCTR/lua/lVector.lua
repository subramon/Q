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

-- ABBREVATIONS cbv = casted_base_vec
-- ABBREVATIONS cnnv = casted_nn_vec

function on_both(
  base_vec,
  nn_vec,
  fn_to_apply
  )
  assert(fn_to_apply(base_vec))
  if ( nn_vec ) then assert(fn_to_apply(nn_vec)) end 
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

function lVector:backup()
  return on_both(self._base_vec, self._nn_vec, Vector.backup)
end

function lVector:check()
  return on_both(self._base_vec, self._nn_vec, Vector.check)
end

-- not from Lua function lVector:check_chunks()
-- directly from struct: lVector:chunk_size_in_bytes()
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
  if ( qconsts.debug ) then self:check() end
  return self
end

-- directly from struct: lVector:field_width()
function lVector:file_name()
  local s1, s2
  s1 = assert(Vector.file_name(self._base_vec))
  if ( self._nn_vec ) then 
    s2 = assert(Vector.file_name(self._nn_vec))
  end
  return s1, s2
end

-- not from Lua function lVector:file_size()

-- directly from struct: lVector:fldtype()
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

-- not from Lua function lVector:file_size()

function lVector:get1(idx)
  local s1, s2
  s1 = assert(Vector.get1(self._base_vec, idx))
  if ( self._nn_vec ) then 
    s2 = assert(Vector.get1(self._nn_vec, idx))
  end
  if ( qconsts.debug ) then self:check() end
  return s1, s2
end

-- not from Lua function lVector:get_name()
-- not from Lua function init_globals()
-- not from Lua function lVector:me()

function lVector:memo(is_memo)
  if ( is_memo == nil ) then 
    is_memo = true
  else
    assert(type(is_memo) == "boolean")
  end
  assert(on_both(self._base_vec, self._nn_vec, Vector.memo))
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector.new(arg)
  local vector = setmetatable({}, lVector)
  -- for meta data stored in vector
  vector._meta = {}

  local num_elements
  local field_type
  local field_width
  local file_name
  local file_names
  local nn_file_name
  local nn_file_names
  local has_nulls = qconsts.has_nulls
  local is_memo = qconsts.is_memo -- referring value from qconsts, default to true

  local is_resurrect = false -- true if file provided in constructor
  assert(type(arg) == "table", "Vector constructor requires table as arg")

  if ( arg.is_memo ~= nil ) then 
    assert(type(arg.is_memo) == "boolean")
    is_memo = arg.is_memo
  end
  field_type = assert(arg.qtype, "lVector needs qtype to be specified")
   --=============================
  field_width = nil
  assert(qconsts.qtypes[field_type], "Invalid qtype provided")
  if field_type == "SC" then
    field_width = assert(arg.width, "Constant length strings need a length to be specified")
    assert(type(field_width) == "number", "field width must be a number")
    assert(field_width >= 2)
  else
    if ( arg.width ) then 
      assert(arg.width == qconsts.qtypes[field_type].width) 
    end
  end
 --=============================
  if ( arg.has_nulls) then 
    assert(type(arg.has_nulls) == "boolean")
    has_nulls = arg.has_nulls
  end
   --=============================
  if arg.gen then 
    is_resurrect = false
    assert(type(arg.gen) == "function" or type(arg.gen) == "boolean" , 
    "supplied generator must be a function or boolean as placeholder ")
    vector._gen = arg.gen
  else -- materialized vector
    is_resurrect = true
    file_name  = arg.file_name
    file_names = arg.file_names
    assert(file_name or file_names)
    if ( file_name  ) then assert( not file_names) end 
    if ( file_names ) then assert( not file_name) end 
    if ( file_name  ) then assert(type(file_name)  == "string") end
    if ( file_names ) then 
      assert(type(file_names) == "table") 
      for k, v in pairs(file_names) do 
        assert(type(v) == "string") 
      end
    end

    if ( has_nulls ) then 
      nn_file_name  = arg.nn_file_name
      nn_file_names = arg.nn_file_names
      assert(nn_file_name or nn_file_names)
    if ( nn_file_name  ) then assert( not nn_file_names) end 
    if ( nn_file_names ) then assert( not nn_file_name) end 
    if ( nn_file_name  ) then assert(type(nn_file_name)  == "string") end
    if ( nn_file_names ) then 
      assert(type(nn_file_names) == "table") 
      for k, v in pairs(nn_file_names) do 
        assert(type(v) == "string") 
      end
    end
    end
  end
  --=============================================
  if ( is_resurrect ) then 
    num_elements = assert(arg.num_elements)
    assert(type(num_elements) == "number")
    if ( file_name ) then -- load from single file 
      vector._base_vec = Vector.rehydrate(field_type, field_width, 
        num_elements, file_name)
      if ( has_nulls ) then 
        vector._nn_vec = Vector.rehydrate("B1", field_width, 
          num_elements, nn_file_name)
      end
    else
      vector._base_vec = Vector.mrehydrate(field_type, field_width, 
        num_elements, file_names)
      if ( has_nulls ) then 
        vector._nn_vec = Vector.mrehydrate("B1", field_width, 
          num_elements, nn_file_names)
      end
    end
  else
    vector._base_vec = Vector.new(field_type, is_memo, field_width)
    if ( has_nulls ) then 
      vector._nn_vec   = Vector.new("B1", is_memo, field_width)
    end
  end
  if ( ( arg.name ) and ( type(arg.name) == "string" ) )  then
    Vector.set_name(vector._base_vec, arg.name)
    if ( vector._nn_vec ) then 
      Vector.set_name(vector._nn_vec, "nn_" .. arg.name)
    end
  end
  --=============================================
  Vector.memo(vector._base_vec, is_memo)
  if ( vector._nn_vec ) then Vector.memo(vector._nn_vec, is_memo) end
  --=============================================
  vector.siblings = {} -- no conjoined vectors
  return vector
end

-- directly from struct lVector:num_elements()
-- not from Lua: num_chunks()
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

-- TODO put1
-- TODO put_chunk
-- TODO rehydate
-- TODO get_chunk

-- not from Lua function lVector:print_timers()
-- not from Lua function lVector:reset_timers()
-- not from Lua function lVector:same_state()

-- TODO P4 I don't think this is really needed. Consider eliminating
function lVector:set_generator(gen)
  assert(self:num_elements() == 0,
    "Cannot set generator once elements generated")
  assert(not self:is_eov(), 
    "Cannot set generator for materialized vector")
  assert(type(gen) == "function")
  self._gen = gen
end

function lVector:put1(s, nn_s)
  assert( ( type(s) == "Scalar" ) or ( type(s) == "CMEM" ) )
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
    status = Vector.eov(self._base_vec)
    if ( self._nn_vec ) then
      status = Vector.eov(self._nn_vec)
    end
  else
    assert(type(base_addr) == "CMEM")
    status = Vector.put_chunk(self._base_vec, base_addr, len)
    assert(status)
    if ( self._nn_vec ) then
      assert(type(nn_addr) == "CMEM")
      status = Vector.put_chunk(self._nn_vec, nn_addr, len)
      assert(status)
    end
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

function lVector:get_one(idx)
  -- TODO More checks to make sure that this is only for 
  -- vectors in file mode. We may need to move vector from buffer 
  -- mode to file mode if we are at last chunk and is_eov == true
  local nn_data, nn_len, nn_scalar
  local base_data, base_len, base_scalar = assert(Vector.get(self._base_vec, idx, 1))
  assert(base_data)
  assert(type(base_data) == "CMEM")
  assert(type(base_len) == "number")
  assert(type(base_scalar) == "Scalar")
  if ( self._nn_vec ) then
    nn_data, nn_len, nn_scalar = assert(Vector.get(self._nn_vec, idx, 1))
    assert(type(nn_scalar) == "Scalar")
  end
  if ( qconsts.debug ) then self:check() end
  return base_scalar, nn_scalar
end

function lVector:chunk(chunk_num)
  local status
  local base_addr, base_len
  local nn_addr,   nn_len  
  --local is_nascent = Vector.is_nascent(self._base_vec)
  local is_nascent = self:is_nascent()
  local is_eov = self:is_eov()
  assert(chunk_num, "chunk_num is a mandatory argument")
  assert(type(chunk_num) == "number")
  assert(chunk_num >= 0)
  local l_chunk_num = chunk_num
  -- There are 2 conditions under which we do not need to compute
  -- cond1 => Vector has been materialized
  local cond1 = is_eov
  -- cond2 => Vector is nascent and you are asking for current chunk
  -- or previous chunk 
  local cond2 = ( not is_eov ) and 
          ( ( ( self:chunk_num() == l_chunk_num ) and 
          ( self:num_in_chunk() > 0 ) ) or 
          ( ( l_chunk_num < self:chunk_num() ) and 
          ( self:is_memo() == true ) ) )
  if ( cond1 or cond2 ) then 
    base_addr, base_len = Vector.get_chunk(self._base_vec, l_chunk_num)
    --=========================================
    if ( not base_addr ) then
      assert(base_len == 0)
      if ( qconsts.debug ) then self:check() end
      return 0
    end
    --=========================================
    if ( self._nn_vec ) then 
      nn_addr,   nn_len   = Vector.get_chunk(self._nn_vec, l_chunk_num)
      assert(nn_addr)
      assert(base_len == nn_len)
    end
    --=========================================
    assert(base_len > 0)
    assert(chk_chunk_return(base_len, base_addr, nn_addr))
    return base_len, base_addr, nn_addr
  else
    assert(type(self._gen) == "function")
    local buf_size, base_data, nn_data = self._gen(chunk_num, self)
    assert(type(buf_size) == "number")
    if ( base_data ) then assert(type(base_data) == "CMEM") end
    self:put_chunk(base_data, nn_data, buf_size)
    if ( buf_size < qconsts.chunk_size ) then self:eov() end
    -- for conjoined vectors
    if self.siblings then
      for k, v in pairs(self.siblings) do
        v:chunk(l_chunk_num)
      end
    end
    if ( qconsts.debug ) then self:check() end
    return self:chunk(l_chunk_num)
    -- TODO P4 ZZ: Could do return chunk_size, base_data, nn_data
    -- That would avoid another function call.
  end
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
  local base_addr, base_len = assert(Vector.get(self._base_vec, 0, 0))
  assert(chk_addr_len(base_addr, base_len))
  if ( self._nn_vec ) then
    nn_addr, nn_len = assert(Vector.get(self._nn_vec, 0, 0))
    assert(chk_addr_len(nn_addr, nn_len, base_len))
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

function lVector:chunk_size_in_bytes()
  if ( qconsts.debug ) then self:check() end
  local cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return cbv[0].chunk_size_in_bytes
end

function lVector:drop_nulls() 
  assert(self:is_eov())
  assert(Vector.delete(self._nn_vec))
  self._nn_vec = nil
  self:set_meta("__has_nulls", false)
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:field_width()
  if ( qconsts.debug ) then self:check() end
  local cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return cbv[0].field_width
end

function lVector:fldtype()
  if ( qconsts.debug ) then self:check() end
  local cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return ffi.string(cbv[0].fldtype)
end

function lVector:get_meta(k)
  if ( qconsts.debug ) then self:check() end
  assert(k)
  assert(type(k) == "string")
  return self._meta[k]
end

function lVector:get_name()
  -- the name of an lVector is the name of its base Vector
  if ( qconsts.debug ) then self:check() end
  cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return ffi.string(cbv[0].name)
end

function lVector:has_nulls()
  if ( qconsts.debug ) then self:check() end
  if ( self._nn_vec ) then return true else return false end
end

function lVector:is_dead()
  if ( qconsts.debug ) then self:check() end
  local cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return cbv[0].is_dead
end

function lVector:is_eov()
  if ( qconsts.debug ) then self:check() end
  local cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return cbv[0].is_eov
end

function lVector:is_memo()
  if ( qconsts.debug ) then self:check() end
  local cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return cbv[0].is_memo
end

function lVector:make_nulls(bvec)
  assert(self:is_eov())
  assert(self._nn_vec == nil) 
  assert(type(bvec) == "lVector")
  assert(bvec:fldtype() == "B1")
  assert(Vector.same_state(self._base_vec, bvec))
  assert(bvec:has_nulls() == false)
  self._nn_vec = bvec._base_vec
  self:set_meta("__has_nulls", true)
  if ( qconsts.debug ) then self:check() end
  return self
end
  

function lVector:meta()
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

function lVector:reincarnate()
  if ( qconsts.debug ) then self:check() end
  -- Not saving lVector because dead
  if ( self:is_dead()) then return nil end
  -- Not saving lVector because not eov
  if ( not self:is_eov()) then return nil end
  -- JIRA: QQ-160
  -- Q.save() should not try to persist global Vectors that have been marked as memo = false
  if ( not self:is_memo()) then return nil end
  
  -- Set persist flag
  self:persist(true)
  
  local T = {}
  T[#T+1] = "lVector ( { "

  T[#T+1] = "qtype = \"" 
  T[#T+1] = self:fldtype()
  T[#T+1] = "\", "

  T[#T+1] = "file_name = \"" 
  T[#T+1] = self:file_name()
  T[#T+1] = "\", "

  if ( self:nn_file_name() ) then 
    T[#T+1] = "nn_file_name = \"" 
    T[#T+1] = self:nn_file_name()
    T[#T+1] = "\", "
  end

  T[#T+1] = "num_elements = "
  T[#T+1] = self:num_elements()
  T[#T+1] = ", "

  T[#T+1] = "width = "
  T[#T+1] = self:field_size()
  T[#T+1] = ", "

  T[#T+1] = " } ) "
  if ( qconsts.debug ) then self:check() end
  return table.concat(T, '')
end

function lVector:num_elements()
  if ( qconsts.debug ) then self:check() end
  local cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  -- As long as eov is not done, we really do not know length of Vector
  -- so we return nil
  -- We could argue that we should return current length.
  -- Not sure if thats a good idea but jury is out.
  if ( cbv[0].is_eov == false ) then 
    -- print("Vector not EOV so length not known")
    return nil 
  end
  return tonumber(cbv[0].num_elements)
end

function lVector:num_chunks()
  if ( qconsts.debug ) then self:check() end
  local cbv = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return tonumber(cbv[0].num_chunks)
end


function lVector:set_meta(k, v)
  if ( qconsts.debug ) then self:check() end
  assert(k)
  -- to destroy a value associated with a key
  if ( not v ) then self._meta[k] = nil; return end
  -- TODO P3 What are valid types for v ?
  if ( not self._meta ) then self._meta = {} end 
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
end
--====================
-- This are aliases to maintain backward compatibility
function lVector:get_chunk(chunk_num)
  return lVector:chunk(chunk_num)
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
