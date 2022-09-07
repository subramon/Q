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

function lVector:check()
  assert(cVector.vctr_chk(self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.vctr_chk(self._nn_vec))
  end 
  return true
end

function lVector:width()
  local width = cVector.width(self._base_vec)
  return width
end

function lVector:num_elements()
  local num_elements = cVector.num_elements(self._base_vec)
  return num_elements
end

function lVector:get_name()
  local name = cVector.get_name(self._base_vec)
  return name
end

function lVector:eov()
  local status = cVector.eov(self._base_vec)
  return status
end
function lVector:is_eov()
  local is_eov = cVector.is_eov(self._base_vec)
  assert(type(is_eov) == "boolean")
  return is_eov
end
function lVector:memo_len()
  return self._memo_len
end
function lVector.new(args)
  local vector = setmetatable({}, lVector)
  vector._meta = {} -- for meta data stored in vector
  assert(type(args) == "table")
  vector._base_vec = assert(cVector.add1(args))
  vector._siblings = {} -- no conjoined vectors
  vector._chunk_num = 0 -- next chunk to ask for 
  vector._memo_len = qcfg.memo_len
  if ( args.gen ) then vector._generator = args.gen end 
  return vector
end
function lVector:memo(memo_len)
  if ( type(memo_len) == "nil" ) then 
    memo_len = qcfg.memo_len
  end
  assert(type(memo_len == "number"))
  -- cannot memo once vector has elements in it 
  if ( self:num_elements() > 0 ) then return nil end 
  self._memo_len = memo_len
end
function lVector:put1(c, n)
  assert(type(c) == "CMEM")
  assert(cVector.put1(self._base_vec, c, n))
end

function lVector:put_chunk(c, n)
  assert(type(c) == "CMEM")
  assert(cVector.put_chunk(self._base_vec, c, n))
end

function lVector:get_chunk(chnk_idx)
  assert(type(chnk_idx) == "number")
  assert(chnk_idx >= 0)
  local x, n = cVector.get_chunk(self._base_vec, chnk_idx)
  assert(type(x) == "CMEM")
  return x, n
end
-- evaluates the vector using a provided generator function
-- when done, is_eov() will be true for this vector
-- if is_eov() at time of call, nothing is done 
function lVector:eval()
  print("EVAL ")
  if ( self:is_eov() ) then return self end 
  local base_len, base_addr, nn_addr 
  repeat
    base_len, base_addr, nn_addr = self:get_chunk(self.chunk_num)
    -- this unget needed because get_chunk increments num readers 
    -- and the eval doesn't actually get the chunk for itself
    cVector.unget_chunk(self._base_vec, self.chunk_num)
    if ( self._nn_vec ) then 
      cVector.unget_chunk(self._nn_vec, self.chunk_num) 
    end
    self.chunk_num = self.chunk_num + 1 
    -- release old chunks
    if ( self._memo_len >= 0 ) then
      local chunk_to_release = (self.chunk_num - self._memo_len) - 1 
      local is_found = cVector.chnk_delete(self._base_vec, chunk_to_release)
      assert(is_found == true)
    end
  until ( base_len ~= num_in_chunk ) 
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

return lVector
