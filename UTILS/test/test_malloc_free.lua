-- FUNCTIONAL
-- This tests whether garbage collection is happening as expected
-- If it were not, this would/should blow through your system's memory
local ffi = require 'Q/UTILS/lua/q_ffi'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local tests = {}

tests.t1 = function()
  for iter = 1, 4096 do 
    local X = {}
    for i = 1, 4096 do 
      X[i] = get_ptr(cmem.new(4096))
    end
    local n = collectgarbage("count")
    -- print(" Iter/n ", iter, n)
  end
  local n = collectgarbage("collect")
  assert(n == 0)

  print("Test t1 succeeded")
end

return tests
