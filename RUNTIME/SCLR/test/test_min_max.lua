require 'Q/UTILS/lua/strict'
local cmem = require 'libcmem' ; 
local Scalar = require 'libsclr' ; 

local tests = {}

-- test setting with min/max 
tests.t1 = function ()
  local maxval = assert(Scalar.new("FLT_MAX", "F4"))
  local minval = assert(Scalar.new("FLT_MIN", "F4"))
  print(maxval)
  print(minval)
  print("Successfully completed test t1")
end

-- return tests
tests.t1()
