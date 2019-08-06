require 'Q/UTILS/lua/strict'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'
local ffi = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local tests = {} 
-- testing get_all function

tests.t1 = function()
  -- generating required .bin file 
  qc.generate_bin(10, "I4", "_in1_I4.bin", "linear")
  local x = lVector(
                    { qtype = "I4", file_name = "_in1_I4.bin"}
                   )
  assert(x:check())
  local len, base_cmem, nn_cmem = x:get_all()
  assert(len == 10)
  assert(base_cmem)
  assert(nn_cmem == nil)
  local X = get_ptr(base_cmem, "I4")
  for i = 1, 10 do
    -- print(X[i-1])
    assert(X[i-1] == i*10)
  end
  print("Successfully completed test t1")
end
  --====================

return tests
