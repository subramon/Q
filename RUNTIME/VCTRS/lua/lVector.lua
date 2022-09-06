local ffi     = require 'ffi'
local cVector = require 'libvctr'
local register_type = require 'Q/UTILS/lua/register_type'
local qcfg = require'Q/UTILS/lua/qcfg'
--====================================
local uqid -- This defines the vector - super important 
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
function lVector.new(args)
  local vector = setmetatable({}, lVector)
  vector.meta = {} -- for meta data stored in vector
  assert(type(args) == "table")
  vector._base_vec = assert(cVector.add1(args))
  vector.siblings = {} -- no conjoined vectors
  return vector
end
function lVector:put1(c, n)
  assert(type(c) == "CMEM")
  assert(cVector.put1(self._base_vec, c, n))
end

return lVector
