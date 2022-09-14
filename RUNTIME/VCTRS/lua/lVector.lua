local ffi     = require 'ffi'
local cVector = require 'libvctr'
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
  self._generator = nil -- IMPORTANT, we no longer have a generator 
  return self
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
function lVector:put1(c, n)
  assert(type(c) == "CMEM")
  assert(cVector.put1(self._base_vec, c, n))
end

function lVector:put_chunk(c, n)
  assert(type(c) == "CMEM")
  assert(cVector.put_chunk(self._base_vec, c, n))
  self._chunk_num = self._chunk_num + 1 
end

function lVector:get1(elem_idx)
  assert(type(elem_idx) == "number")
  if (elem_idx < 0) then return nil end
  local sclr = cVector.get1(self._base_vec, elem_idx)
  return sclr
end

function lVector:get_chunk(chnk_idx)
  assert(type(chnk_idx) == "number")
  assert(chnk_idx >= 0)
  assert(chnk_idx <= self._chunk_num)
  if ( chnk_idx == self._chunk_num ) then 
    -- invoke the generator 
    local num_elements, buf, nn_buf = self._generator(self._chunk_num)
    assert(type(num_elements) == "number")
    if ( num_elements == 0 ) then  -- nothing more to generate
      self:eov()  -- vector is at an end 
      -- Following increment seems unnecessary but is important to 
      -- keep consistency with put_chunk
      return 0
    else
      self:put_chunk(buf, num_elements)
      -- TODO P1 IMPORTANT What about nn_buf??? 
      return num_elements, buf
    end 
  else 
    print("Archival chunk num " .. self._chunk_num)
    local x, n = cVector.get_chunk(self._base_vec, chnk_idx)
    if ( x ~= nil ) then assert(type(x) == "CMEM") end 
    return x, n
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
        print("Deleting chunk " .. chunk_to_release)
        local is_found = 
          cVector.chunk_delete(self._base_vec, chunk_to_release)
        -- assert(is_found == true)
        if ( is_found == false ) then 
          print("Chunk was not found " .. chunk_to_release)
        end
      end
    end
  until ( num_elements ~= self._max_num_in_chunk ) 
  print("lVector: eov")
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
  print("lVector; eval() done")
  return self
end

function lVector:pr(opfile, lb, ub)
  local nn = self._nn_vec
  if ( nn == nil ) then
    nn = lVector.null()
  end
  if ( opfile ) then
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
    assert(ub > lb) 
    assert(ub <= self:num_elements())
  else
    ub = self:num_elements()
  end
  --=================================
  -- assert(cVector.pr(self._base_vec, self._nn_vec, opfile, lb, ub))
  assert(cVector.pr(self._base_vec, nn, opfile, lb, ub))
  return true
end

function lVector.null()
  return cVector.null()
end

return lVector
