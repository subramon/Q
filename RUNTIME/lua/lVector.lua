-- TODO Document properly. Key of set_meta is always a string
-- If it is something that has special meaning to Q, starts with __
-- If not, any other string will work but do not use __ as a prefix
local ffi		= require 'Q/UTILS/lua/q_ffi'
local qconsts		= require 'Q/UTILS/lua/q_consts'
local log		= require 'Q/UTILS/lua/log'
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
-- -- TODO Indrajeet to change
-- local original_type = type  -- saves `type` function
-- -- monkey patch type function
-- type = function( obj )
--    local otype = original_type( obj )
--    if  otype == "table" and getmetatable( obj ) == lVector then
--       return "lVector"
--    end
--    return otype
-- end

function lVector:get_name()
  -- the name of an lVector is the name of its base Vector
  if ( qconsts.debug ) then self:check() end
  -- note that Lua is master and C is just for debugging
  -- TODO P4 We have a problem becuase when restore happens, the name
  -- is set on the Lua side but not on the C side 
  if ( self._meta.name ) then 
    local status = Vector.set_name(self._base_vec, self._meta.name)
    assert(status)
  end
  return Vector.get_name(self._base_vec)
end

function lVector:set_name(vname)
  -- the name of an lVector is the name of its base Vector
  if ( qconsts.debug ) then self:check() end
  assert(type(vname) == "string")
  assert(#vname > 0)
  -- set on the C side to help with debugging
  local status = Vector.set_name(self._base_vec, vname)
  assert(status)
  -- set on the Lua side 
  self._meta.__name = vname
  return self
end

function lVector:cast(new_field_type)
  assert(new_field_type)
  assert(type(new_field_type) == "string")
  local new_field_width
  if is_base_qtype(new_field_type) then 
    new_field_width = qconsts.qtypes[new_field_type].width
  elseif ( new_field_type == "B1" ) then
    new_field_width = 0
  else
    assert(nil, "Cannot cast to ", new_field_type)
  end
  if ( self._nn_vec ) then 
    assert(nil, "TO BE IMPLEMENTED")
  end
  local status = Vector.cast(self._base_vec,new_field_type, new_field_width)
  assert(status)
  if ( qconsts.debug ) then self:check() end
  return self
end

-- Older version of is_memo, kept just for reference if required in future
function lVector:is_memo_old()
  if ( qconsts.debug ) then self:check() end
  return Vector.is_memo(self._base_vec)
end

function lVector:is_dead()
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.is_dead
end

function lVector:is_mono()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.is_mono
end

function lVector:is_memo()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.is_memo
end

function lVector:is_nascent()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.is_nascent
end

function lVector:num_in_chunk()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.num_in_chunk
end

function lVector:file_size()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  -- added tonumber() because casted_base_vec.file_size is of type cdata
  return tonumber(casted_base_vec.file_size)
end

function lVector:is_eov()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  local x =  casted_base_vec.is_eov
  assert(type(x) == "boolean")
  return casted_base_vec.is_eov
end

function lVector:no_memcpy(cmem)
  if ( qconsts.debug ) then self:check() end
  local status = Vector.no_memcpy(self._base_vec, cmem)
  return self
end

function lVector:flush_buffer()
  if ( qconsts.debug ) then self:check() end
  local status = Vector.flush_buffer(self._base_vec)
  return self
end

function lVector.new(arg)
  local vector = setmetatable({}, lVector)
  -- for meta data stored in vector
  vector._meta = {}

  local num_elements
  local qtype
  local field_width
  local file_name
  local nn_file_name
  local has_nulls
  local is_nascent
  local is_memo = qconsts.is_memo -- referring value from qconsts, default to true
  local q_data_dir = qconsts.Q_DATA_DIR

  assert(qc.isdir(q_data_dir), "Q_DATA_DIR not present")
  assert(type(arg) == "table", "Vector constructor requires table as arg")

  if ( arg.is_memo ~= nil ) then 
    assert(type(arg.is_memo) == "boolean")
    is_memo = arg.is_memo
  end
  -- Validity of qtype will be checked for by vector
  qtype = assert(arg.qtype, "lVector needs qtype to be specified")
   --=============================
  field_width = nil
  assert(qconsts.qtypes[qtype], "Invalid qtype provided")
  if qtype == "SC" then
    field_width = assert(arg.width, "Constant length strings need a length to be specified")
    assert(type(field_width) == "number", "field width must be a number")
    assert(field_width >= 2)
  else
    if (arg.width ) then 
      assert(arg.width == qconsts.qtypes[qtype].width) 
    end
  end
   --=============================

  if arg.gen then 
    is_nascent = true
    if ( arg.has_nulls == nil ) then
      has_nulls = true
    else
      assert(type(arg.has_nulls) == "boolean")
      has_nulls = arg.has_nulls
    end
    assert(type(arg.gen) == "function" or type(arg.gen) == "boolean" , 
    "supplied generator must be a function or boolean as placeholder ")
    vector._gen = arg.gen
  else -- materialized vector
     file_name = assert(arg.file_name, 
     "lVector needs a file_name to read from")
     assert(type(file_name) == "string", 
     "lVector's file_name must be a string")

    if arg.nn_file_name then
      nn_file_name = arg.nn_file_name
      assert(type(nn_file_name) == "string", 
      "Null vector's file_name must be a string")
      has_nulls = true
      if ( arg.has_nulls ) then assert(arg.has_nulls == true) end
    else
      has_nulls  = false
      if ( arg.has_nulls ) then assert(arg.has_nulls == false) end
    end
    is_nascent = false
  end

  if ( qtype == "SC" ) then 
    qtype = qtype .. ":" .. tostring(field_width)
  end
  if ( arg.num_elements ) then  -- TODO P4: Move to Lua style
    num_elements = arg.num_elements
  end
  vector._base_vec = Vector.new(qtype, q_data_dir, file_name, is_memo, 
    num_elements)
  assert(vector._base_vec)
  -- added tonumber() because returned num_elements was of type cdata
  local num_elements = tonumber(ffi.cast("VEC_REC_TYPE *", vector._base_vec).num_elements)
  if ( has_nulls ) then 
    if ( not is_nascent ) then 
      assert(num_elements > 0)
    end
    vector._nn_vec = Vector.new("B1", q_data_dir, nn_file_name, is_memo, num_elements)
    assert(vector._nn_vec)
  end
  if ( ( arg.name ) and ( type(arg.name) == "string" ) )  then
    Vector.set_name(vector._base_vec, arg.name)
    if ( vector._nn_vec ) then 
      Vector.set_name(vector._nn_vec, "nn_" .. arg.name)
    end
  end
  vector.siblings = {} -- no conjoined vectors
  return vector
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
function lVector:persist(is_persist)
  local base_status = true
  local nn_status = true
  if ( is_persist == nil ) then 
    is_persist = true
  else
    assert(type(is_persist) == "boolean")
  end
  base_status = Vector.persist(self._base_vec, is_persist)
  if ( self._nn_vec ) then 
    nn_status = Vector.persist(self._nn_vec, is_persist)
  end
  if ( qconsts.debug ) then self:check() end
  if ( base_status and nn_status ) then
    return self
  else
    return nil
  end
end

function lVector:nn_vec()
  -- TODO Can only do this when vector has been materialized
  -- That is because one generator starts feeding 2 vectors and 
  -- we are not prepared for that
  -- P1 Fix this code. In current state, it is not working
  assert(self:is_eov())
  local vector = setmetatable({}, lVector)
  vector._meta = {}
  vector._base_vec = self._nn_vec
  if ( qconsts.debug ) then self:check() end
  return vector
end
  
function lVector:drop_nulls()
  assert(self:is_eov())
  self._nn_vec = nil
  self:set_meta("__has_nulls", false)
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:make_nulls(bvec)
  assert(self:is_eov())
  assert(self._nn_vec == nil) 
  assert(type(bvec) == "lVector")
  assert(bvec:fldtype() == "B1")
  assert(bvec:num_elements() == self:num_elements())
  assert(bvec:has_nulls() == false)
  self._nn_vec = bvec._base_vec
  self:set_meta("__has_nulls", true)
  if ( qconsts.debug ) then self:check() end
  return self
end
  
function lVector:memo(is_memo)
  local base_status, nn_status = true, true
  if ( is_memo == nil ) then 
    is_memo = true
  else
    assert(type(is_memo) == "boolean")
  end
  base_status = Vector.memo(self._base_vec, is_memo)
  if ( self._nn_vec ) then 
    nn_status = Vector.memo(self._nn_vec, is_memo)
  end
  if ( qconsts.debug ) then self:check() end
  assert ( base_status and nn_status ) 
  return self
end

-- TODO P4: mono code is same as memo code. But we have duplicated it :-(
function lVector:mono(is_mono)
  local base_status, nn_status = true, true
  if ( is_mono == nil ) then 
    is_mono = true
  else
    assert(type(is_mono) == "boolean")
  end
  base_status = Vector.mono(self._base_vec, is_mono)
  if ( self._nn_vec ) then 
    nn_status = Vector.mono(self._nn_vec, is_mono)
  end
  if ( qconsts.debug ) then self:check() end
  assert ( base_status and nn_status ) 
  return self
end


function lVector:chunk_num()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.chunk_num
end

function lVector:chunk_size()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.chunk_size
end

function lVector:has_nulls()
  if ( qconsts.debug ) then self:check() end
  if ( self._nn_vec ) then return true else return false end
end

function lVector:num_elements()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  -- added tonumber() because casted_base_vec.num_elements is of type cdata
  return tonumber(casted_base_vec.num_elements)
end

function lVector:length()
  -- As long as eov is not done, we really do not know length of Vector
  -- so we return nil
  -- We could argue that we should return current length.
  -- Not sure if thats a good idea but jury is out.
  if ( not self:is_eov() ) then 
    -- print("Vector not EOV so length not known")
    return nil 
  end
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  -- added tonumber() because casted_base_vec.num_elements is of type cdata
  return tonumber(casted_base_vec.num_elements)
end

-- Older version of fldtype(), kept just for reference if required in future
function lVector:fldtype_old()
  if ( qconsts.debug ) then self:check() end
  return Vector.fldtype(self._base_vec)
end

function lVector:fldtype()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return ffi.string(casted_base_vec.field_type)
end

function lVector:qtype()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return ffi.string(casted_base_vec.field_type)
end

function lVector:field_size()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.field_size
end

function lVector:field_width()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.field_size
end

function lVector:file_name()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return ffi.string(casted_base_vec.file_name)
end

function lVector:nn_file_name()
  local vec_meta = self:meta()
  local nn_file_name = nil
  if vec_meta.nn then
    nn_file_name = assert(vec_meta.nn.file_name)
  end
  if ( qconsts.debug ) then self:check() end
  return nn_file_name
end

function lVector:check()
  local chk = Vector.check(self._base_vec)
  assert(chk, "Error on base vector")
  local num_elements = Vector.num_elements(self._base_vec)
  if ( self._nn_vec ) then
    local nn_num_elements = Vector.num_elements(self._nn_vec)
    chk = Vector.check(self._nn_vec)
    assert(num_elements == nn_num_elements)
    -- TODO P4 Anything else to be same between base_vec and nn_vec?
    assert(chk, "Error on nn vector")
  end
  return true
end

-- TODO P4 I don't think this is really needed. Consider eliminating
function lVector:set_generator(gen)
  assert(self:num_elements() == 0,
    "Cannot set generator once elements generated")
  assert(not self:is_eov(), 
    "Cannot set generator for materialized vector")
  assert(type(gen) == "function")
  self._gen = gen
end

function lVector:eov()
  local status = Vector.eov(self._base_vec)
  assert(status)
  if self._nn_vec then 
    local status = Vector.eov(self._nn_vec)
    assert(status)
  end
-- destroy generator (if any) and thereby 
-- (1) release resources held by it 
-- (2) no more data can be added to Vector
  self._gen = nil 
  if ( self:num_elements() == 0 ) then return nil end
  if ( qconsts.debug ) then self:check() end
  assert( self._base_vec:is_eov() == true)
  return true
end

function lVector:put1(s, nn_s)
  assert(s)
  assert( ( type(s) == "Scalar" ) or ( type(s) == "CMEM" ) )
  local status = Vector.put1(self._base_vec, s)
  assert(status)
  if ( self._nn_vec ) then 
    assert(nn_s)
    assert(type(nn_s) == "Scalar")
    assert(nn_s:fldtype() == "B1")
    local status = Vector.put1(self._nn_vec, nn_s)
    assert(status)
  end
  if ( qconsts.debug ) then self:check() end
end

function lVector:start_write(is_read_only_nn)
  if ( is_read_only_nn ) then 
    assert(type(is_read_only_nn) == "boolean")
  end
  local nn_X, nn_nX
  local X, nX = Vector.start_write(self._base_vec)
  assert(X)
  assert(type(nX) == "number")
  assert(nX > 0)
  if ( self._nn_vec ) then
    if ( is_read_only_nn ) then 
      nn_X, nn_nX = assert(Vector.get(self._nn_vec, 0, 0))
    else
      nn_X, nn_nX = Vector.start_write(self._nn_vec)
    end
    assert(nn_nX == nX)
    assert(nn_nX)
  end
  if ( qconsts.debug ) then self:check() end
  return nX, X, nn_X
end

function lVector:end_write()
  local status = Vector.end_write(self._base_vec)
  assert(status)
  if ( self._nn_vec ) then
    local status = Vector.end_write(self._nn_vec)
    assert(status)
  end
  if ( qconsts.debug ) then self:check() end
  return true
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

function lVector:delete()
  print("Deleting for ", self:get_name())
  -- This method free up all vector resources
  assert(self._base_vec)
  local has_nulls = self:has_nulls()
  local status = Vector.delete(self._base_vec)
  assert(status)

  -- Check for nulls
  if ( has_nulls ) then
    status = Vector.delete(self._nn_vec)
    assert(status)
  end
  return status
end

function lVector:clone(optargs)
  assert(self._base_vec)
  -- Now we are supporting clone for non_eov vector as well, so commenting below condition
  -- assert(self:is_eov(), "can clone vector only if is EOV")

  local q_data_dir = qconsts.Q_DATA_DIR
  assert(qc.isdir(q_data_dir), "Q_DATA_DIR not present")

  local vector = setmetatable({}, lVector)
  -- for meta data stored in vector
  vector._meta = {}

  vector._base_vec = Vector.clone(self._base_vec, q_data_dir)
  assert(vector._base_vec)

  -- Check for nulls
  if ( self:has_nulls() ) then
    vector._nn_vec = Vector.clone(self._nn_vec, q_data_dir)
    assert(vector._nn_vec) 
  end

  -- copy aux metadata if any
  for i, v in pairs(self._meta) do
    vector._meta[i] = v
  end

  -- check for the optargs
  if optargs then
    assert(type(optargs) == "table")
    for i, v in pairs(optargs) do
      -- currently entertaining just "name" field, in future there might be many other fields
      if i == "name" then
        Vector.set_name(vector._base_vec, v)
      end
    end
  end
  return vector
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

function lVector:get_all()
  assert(self:is_eov())
  local nn_addr, nn_len
  local base_addr, base_len = assert(Vector.get(self._base_vec, 0, 0))
  assert(base_len > 0)
  assert(base_addr)
  if ( self._nn_vec ) then
    nn_addr, nn_len = assert(Vector.get(self._nn_vec, 0, 0))
    assert(nn_len == base_len)
    assert(nn_addr)
  end
  if ( qconsts.debug ) then self:check() end
  return base_len, base_addr, nn_addr
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
      print(base_len, self:get_name())
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
  if ( not self:is_dead()) then return nil end
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


function lVector:set_meta(k, v)
  if ( qconsts.debug ) then self:check() end
  assert(k)
  -- assert(v): do not do this since it is used to set meta of key to nil
  -- NOT VALID CHECK assert(type(k) == "string") 
  -- TODO P3 WHY IS ABOVE THE CASE?
  -- value can be number or boolean or string or table 
  if ( not self._meta ) then self._meta = {} end 
  if ( string.sub(s, 1, 2) ~= "__" ) then 
    -- this is NOT a reserved word
    self._meta[k] = v
    return true
  end
  -- to destroy a value associated with a key
  if ( not v ) then self._meta[k] = nil; return end
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

function lVector:get_meta(k)
  if ( qconsts.debug ) then self:check() end
  assert(k)
  assert(type(k) == "string")
  return self._meta[k]
end

return lVector
