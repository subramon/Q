-- All attributes of vector start with _ to distinguish it from methods
-- So, we have lVector.width but we have self._base_vec or self._chunk_num
-- All meta data, by convention, is in _meta.* e.g.,
-- self._meta.meaning or self._meta.max
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local register_type = require 'Q/UTILS/lua/register_type'
local qcfg = require'Q/UTILS/lua/qcfg'
--====================================
local lVector = {}
lVector.__index = lVector

-- Following hack of __gc is needed because of inability to set
-- __gc on anything other than userdata in 5.1.* 
-- This is why we need cVector.c and cannot directly ffi to the 
-- C files in ../src/
-- Given that we are paying the price of using the C API, I think
-- we can dispense with this __gc business
-- local setmetatable = require 'Q/UTILS/lua/rs_gc'
local mt = {
   __call = function (cls, ...)
      return cls.new(...)
   end,
 }
setmetatable(lVector, mt)

register_type(lVector, "lVector")

function lVector:check(is_at_rest, is_for_all)
  if ( type(is_at_rest) == "nil" ) then
    is_at_rest = false
  end
  assert(type(is_at_rest) == "boolean")

  if ( type(is_for_all) == "nil" ) then
    is_for_all = false
  end
  assert(type(is_for_all) == "boolean")

  local status = cVector.chk(self._base_vec, is_at_rest, is_for_all)
  local nn_status = true
  if ( not is_for_all ) then 
    if ( self._nn_vec ) then 
      nn_status = cVector.chk(self._nn_vec, is_at_rest, is_for_all)
    end
  end 
  return (status and nn_status)
end

function lVector:width()
  local width = cVector.width(self._base_vec)
  return width
end

function lVector:ref_count()
  local ref_count = cVector.ref_count(self._base_vec)
  return ref_count
end

function lVector:memo_len()
  local memo_len = cVector.memo_len(self._base_vec)
  return memo_len
end

function lVector:max_num_in_chnk()
  local max_num_in_chnk = cVector.max_num_in_chnk(self._base_vec)
  return max_num_in_chnk
end

function lVector:num_elements()
  local num_elements = cVector.num_elements(self._base_vec)
  return num_elements
end

function lVector:name()
  local name = cVector.name(self._base_vec)
  return name
end

function lVector:set_name(name)
  assert(type(name) == "string")
  local status = cVector.set_name(self._base_vec, name)
  return self
end
function lVector:drop(level)
  assert(type(level) == "number")
  assert(cVector.drop_l1_l2(self._base_vec, level))
  if ( self._nn_vec ) then 
    assert(cVector.drop_l1_l2(self._nn_vec, level))
  end
  return self
end
function lVector:l1_to_l2()
  local status = cVector.l1_to_l2(self._base_vec)
  return self
end
function lVector:persist()
  local status = cVector.persist(self._base_vec)
  return self
end
function lVector:eov()
  local status = cVector.eov(self._base_vec)
  if ( self._nn_vec ) then status = cVector.eov(self._nn_vec) end 
  -- TODO P1 Should we get rid of chunk_num now ?
  self._generator = nil -- IMPORTANT, we no longer have a generator 
  return self
end
function lVector:get_nulls()
  if ( not self._nn_vec ) then return nil end 
  return self._nn_vec
end
function lVector:break_nulls()
  self._nn_vec = nil
end
function lVector:has_nulls()
  if ( self._nn_vec ) then return true else return false end 
end
function lVector:is_eov()
  local is_eov = cVector.is_eov(self._base_vec)
  assert(type(is_eov) == "boolean")
  return is_eov
end
function lVector:nop()
  local status = cVector.nop(self._base_vec)
  assert(type(status) == "boolean")
  return status
end
function lVector:is_persist()
  local is_persist = cVector.is_persist(self._base_vec)
  assert(type(is_persist) == "boolean")
  return is_persist
end
function lVector:has_gen()
  if ( self._generator ) then return true  else return false end 
end
function lVector:uqid()
  local uqid = cVector.uqid(self._base_vec)
  assert(type(uqid) == "number")
  return uqid
end
function lVector:memo_len()
  return self._memo_len
end
function lVector:qtype()
  return self._qtype
end
function lVector.new(args)
  local vector = setmetatable({}, lVector)
  vector._meta = {} -- for meta data stored in vector
  assert(type(args) == "table")
  if ( args.uqid )  then 
    assert(type(args.uqid) == "number")
    assert(args.uqid > 0)
    vector._base_vec = assert(cVector.rehydrate(args))
    -- get following from cVector
    -- max_num_in_chnk
    -- memo_len
    vector._max_num_in_chnk = cVector.max_num_in_chnk(vector._base_vec)
    vector._memo_len        = cVector.memo_len(vector._base_vec)
    vector._qtype           = cVector.qtype(vector._base_vec)
    -- If vector has nulls, do following 
    if ( args.nn_uqid ) then 
      local nn_uqid = args.nn_uqid
      assert(type(nn_uqid) == "number")
      assert(nn_uqid > 0)
      vector._nn_vec = assert(cVector.rehydrate({ uqid = nn_uqid}))
    end 
    vector:persist(false) -- IMPORTANT
    return vector 
  end

  vector._siblings = {} -- no conjoined vectors
  vector._chunk_num = 0 -- next chunk to ask for 
  if ( args.gen ) then vector._generator = args.gen end 
  --=================================================
  assert(type(args.qtype) == "string")
  vector._qtype = args.qtype
  --=================================================
  if ( args.max_num_in_chunk ) then 
    vector._max_num_in_chunk = args.max_num_in_chunk
  else
    vector._max_num_in_chunk = qcfg.max_num_in_chunk
    -- NOTE: Following needed for cVector.add*
    args.max_num_in_chunk = vector._max_num_in_chunk 
  end
  assert(type(vector._max_num_in_chunk) == "number")
  assert(vector._max_num_in_chunk > 0)
  --=================================================
  if ( args.memo_len ) then 
    vector._memo_len = args.memo_len
  else
    vector._memo_len = qcfg.memo_len
    -- NOTE: Following needed for cVector.add*
    args.memo_len = vector._memo_len 
  end
  assert(type(vector._memo_len) == "number")
  --=================================================
  vector._base_vec = assert(cVector.add1(args))
  if ( args.has_nulls ) then 
    -- assemble args for nn Vector 
    local nn_args = {}
    nn_args.qtype = "BL" -- TODO P1 Move this to B1 
    if ( args.name ) then 
      nn_args.name = "nn_" .. args.name 
    end
    if ( args.max_num_in_chunk ) then 
      nn_args.max_num_in_chunk  = args.max_num_in_chunk 
    end
    if ( args.memo_len ) then 
      nn_args.memo_len  = args.memo_len 
    end
    ----------------------------------- 
    vector._nn_vec = assert(cVector.add1(nn_args))
  end 
  --=================================================
  return vector
end
function lVector:memo(memo_len)
  if ( type(memo_len) == "nil" ) then 
    memo_len = qcfg.memo_len
  end
  assert(type(memo_len == "number"))
  -- cannot memo once vector has elements in it 
  if ( self:num_elements() > 0 ) then return nil end 
  assert(cVector.set_memo(self._base_vec, memo_len))
  self._memo_len = memo_len
  return self
end

function lVector:unset_nulls()
  self._nn_vec = nil
end

function lVector:set_nulls(nn_vec)
  assert(not self._nn_vec) -- must not have an nn_vec currently
  assert(self:is_eov()) -- must be ended for input
  --===============
  assert(type(nn_vec) == "lVector")
  assert(nn_vec:has_nulls() == false) -- nn cannot have nulls
  assert(nn_vec:is_eov()) -- nn vec must also be ended for input
  assert(nn_vec:num_elements() == self:num_elements()) -- sizes must match
  local nn_qtype = nn_vec:qtype() 
  assert(nn_qtype == "BL") -- TODO consider adding B1 

  self._nn_vec = nn_vec
  return self 
end

function lVector:put1(sclr, nn_sclr)
  --========================
  assert(type(sclr) == "Scalar")
  --========================
  -- nn_sclr can be provided only if vector has nulls
  if ( type(nn_sclr) ~= "nil" ) then assert(self._nn_vec) end
  -- if vector has nulls, nn_sclr must be provided
  if ( self._nn_vec ) then assert(type(nn_sclr) == "Scalar") end
  -- if nn_sclr is provided it must be BL Scalar
  if ( type(nn_sclr) ~= "nil" ) then
    assert(type(nn_sclr) == "Scalar")
    assert(nn_sclr:qtype() == "BL") 
  end
  --========================
  assert(cVector.put1(self._base_vec, sclr))
  if ( self._nn_vec ) then 
    assert(cVector.put1(self._nn_vec, nn_sclr))
  end
end

function lVector:putn(col, n, nn_col)
  --========================
  assert(type(col) == "CMEM")
  --========================
  if ( type(n) == "nil" ) then n = 1 end
  assert(type(n) == "number"); assert(n > 0)
  --========================
  -- nn_col can be provided only of vector has nulls
  if ( type(nn_col) ~= "nil" ) then assert(self._nn_vec) end
  -- if vector has nulls, nn_col must be provided 
  if ( self._nn_vec ) then assert(nn_col) end 
  -- if nn_col, then it must be CMEM 
  if ( nn_col ) then assert(type(nn_col) == "CMEM") end
  --========================
  assert(cVector.putn(self._base_vec, col, n))
  if ( self.nn_vec ) then 
    assert(cVector.putn(self._nn_vec, nn_col, n))
  end
end

function lVector:put_chunk(c, n, nn_c)
  assert(type(c) == "CMEM")
  assert(cVector.put_chunk(self._base_vec, c, n))
  if ( self._nn_vec ) then 
    assert(type(nn_c) == "CMEM")
    assert(cVector.put_chunk(self._nn_vec, nn_c, n))
  end
  self._chunk_num = self._chunk_num + 1 
end

function lVector:get1(elem_idx)
  local nn_sclr
  assert(type(elem_idx) == "number")
  if (elem_idx < 0) then return nil end
  local sclr = cVector.get1(self._base_vec, elem_idx)
  if ( type(sclr) ~= "nil" ) then assert(type(sclr) == "Scalar") end
  if ( self._nn_vec ) then 
    nn_sclr = cVector.get1(self._nn_vec, elem_idx)
    assert(type(nn_sclr) == type(sclr))
    if ( nn_sclr ) then
      assert(nn_sclr:qtype() == "BL")
    end
  end
  return sclr, nn_sclr
end

function lVector:unget_chunk(chnk_idx)
  cVector.unget_chunk(self._base_vec, chnk_idx)
  if ( self._nn_vec ) then 
    cVector.unget_chunk(self._nn_vec, chnk_idx)
  end
end

function lVector:get_chunk(chnk_idx)
  assert(type(chnk_idx) == "number")
  assert(chnk_idx >= 0)
  local to_generate 
  if ( self:is_eov() ) then
    to_generate = false
  else
    if ( chnk_idx < self._chunk_num ) then 
      to_generate = false
    elseif ( chnk_idx == self._chunk_num ) then 
      to_generate = true
    else
      error("")
    end
  end
  if ( to_generate ) then 
    -- invoke the generator 
    if ( type(self._generator) == "nil" ) then return 0, nil end 
    local num_elements, buf, nn_buf = self._generator(self._chunk_num)
    assert(type(num_elements) == "number")
    --==============================
    if ( num_elements > 0 ) then  
      assert(type(buf) == "CMEM")
      self:put_chunk(buf, num_elements, nn_buf)
    end
    --==============================
    if ( num_elements < self._max_num_in_chunk ) then 
      -- nothing more to generate
      self:eov()  -- vector is at an end 
      -- Following increment seems unnecessary but is important to 
      -- keep consistency with put_chunk
    end
    --==============================
    if ( num_elements == 0 ) then
      return 0
    else 
      return num_elements, buf, nn_buf
    end 
  else 
    -- print("Archival get_chunk " .. chnk_idx)
    local x, n = cVector.get_chunk(self._base_vec, chnk_idx)
    if ( x == nil ) then return 0, nil end 
    assert(type(n) == "number")
    assert(type(x) == "CMEM")
    return n, x 
  end
end
-- evaluates the vector using a provided generator function
-- when done, is_eov() will be true for this vector
-- if is_eov() at time of call, nothing is done 
function lVector:eval()
  if ( self:is_eov() ) then return self end 
  repeat
    local num_elements, buf, nn_buf = self:get_chunk(self._chunk_num)
    assert(type(num_elements) == "number")
    -- this unget needed because get_chunk increments num readers 
    -- and the eval doesn't actually get the chunk for itself
    -- The -1 below is important. This is because get_chunk would have 
    -- called put_chunk which would have incremented chunk_num
    if ( num_elements == 0 ) then 
      cVector.unget_chunk(self._base_vec, self._chunk_num-1)
      if ( self._nn_vec ) then 
        cVector.unget_chunk(self._nn_vec, self._chunk_num-1) 
      end
    end 
    --===========================
    -- release old chunks
    -- NOTE that memo_len == 0 is meanignless 
    -- because we always keep the last chunk generated
    if ( ( self._memo_len >= 0 ) and ( num_elements > 0 ) ) then
      local chunk_to_release = (self._chunk_num-1) - self._memo_len
      if ( chunk_to_release >= 0 ) then 
        -- print("Deleting chunk " .. chunk_to_release)
        local is_found = 
          cVector.chunk_delete(self._base_vec, chunk_to_release)
        -- assert(is_found == true)
        if ( is_found == false ) then 
          print("Chunk was not found " .. chunk_to_release)
        end
      end
    end
  until ( num_elements ~= self._max_num_in_chunk ) 
  assert(self:is_eov())
  --[[ TODO THINK P1 
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
  --]]
  if ( qcfg.debug ) then self:check() end
  return self
end

function lVector:pr(opfile, lb, ub, format)
  local nn = self._nn_vec
  if ( nn == nil ) then
    nn = lVector.null()
  end
  if ( ( opfile )  and ( #opfile > 0 ) ) then
    assert(type(opfile) == "string")
  else
    opfile = ffi.NULL
  end
  --=================================
  if ( lb ) then
    assert(type(lb) == "number")
    assert(lb >= 0)
  else
    lb = 0
  end
  --=================================
  if ( ub ) then -- upper bound exclusive
    assert(type(ub) == "number")
    if ( ub ~= 0 ) then assert(ub > lb)  end
    assert(ub <= self:num_elements())
  else
    ub = self:num_elements()
  end
  --=================================
  if ( ( format ) and (#format > 0 ) ) then
    assert(type(format) == "string")
  else
    format = ""
  end
  --=================================
  -- assert(cVector.pr(self._base_vec, self._nn_vec, opfile, lb, ub))
  assert(cVector.pr(self._base_vec, nn, opfile, lb, ub, format))
  return true
end
function lVector:get_meta(key)
  assert(type(key) == "string")
  if ( self._meta[key] ) then 
    return self._meta[key] 
  else
    return nil
  end
end
function lVector:unset_meta(key)
  assert(type(key) == "string")
  if ( self._meta[key] ) then 
    self._meta[key] = nil
  end
end
function lVector:set_meta(key, value)
  assert(type(key) == "string")
  assert(value)
  self._meta[key] = value
end

function lVector.null()
  return cVector.null()
end

return lVector
