local ffi     = require 'ffi'
local cVector = require 'libvctr'
--====================================
local uqid -- This defines the vector - super important 
local lVector = {}
lVector.__index = lVector

local setmetatable = require '__gc'
local mt = {
   __call = function (cls, ...)
      return cls.new(...)
   end,
   __gc = function() 
     print("Calling gc ")
     local is_found  = ffi.new("bool[?]", 1)
     is_found = ffi.cast("bool *", is_found)
    local status = cVector.vctr_del(self.uqid, is_found)
    if ( status ~= 0 ) then print("Error in gc") end 
    -- print("DONE Calling gc ")
  end
}
setmetatable(lVector, mt)

-- register_type(lVector, "lVector")

function lVector:check()
  assert(cVector.vctr_chk(self._base_vec))
  if ( self._nn_vec ) then 
    assert(cVector.vctr_chk(self._nn_vec))
  end 
  return true
end

function lVector:num_chunks()
  local num_chunks = fff.new("uint32_t[?]", 1)
  num_chunks = ffi.cast("uint32_t *", num_chunks) 
  local status = cVector.num_chunks(self.uqid, num_chunks)
  assert(status == 0)
  return num_chunks
end

function lVector:num_elements()
  local num_elements = fff.new("uint32_t[?]", 1)
  num_elements = ffi.cast("uint32_t *", num_elements) 
  local status = cVector.num_elements(self.uqid, num_elements)
  assert(status == 0)
  return num_elements
end

function lVector:get_name()
  local name = fff.new("char *[?]", 1)
  name = ffi.cast("char **", 1) 
  local name = cVector.get_name(self.uqid)
  return name
end

function lVector:is_eov()
  local is_eov = fff.new("bool[?]", 1)
  is_eov = ffi.cast("bool *", is_eov) 
  local status = cVector.is_eov(self.uqid, is_eov)
  assert(status == 0)
  return num_elements
end
function lVector.new(args)
  local vector = setmetatable({}, lVector)
  vector.meta = {} -- for meta data stored in vector
  assert(type(args) == "table")
  local l_uqid = ffi.new("uint32_t[?]", 1)
  l_uqid = ffi.cast("uint32_t *", l_uqid);
  assert(cVector.add1(args))
  vector.uqid = l_uqid; -- IMPORTANT 
  vector.siblings = {} -- no conjoined vectors
  return vector
end
return lVector
