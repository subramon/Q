local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'
local ffi = require 'ffi'

-- generating .bin files required for materialized vector
local q_type = "I4"
local num_values = 10
-- generating .bin files required for materialized vector
qc.generate_bin(num_values, q_type, "_in1_I4.bin", "linear" )
q_type = "B1"
qc.generate_bin(num_values, q_type, "_nn_in1.bin", nil)

local tests = {} 
--
tests.t1 = function()
  local x = lVector(
  { qtype = "I4", file_name = "_in1_I4.bin", nn_file_name = "_nn_in1.bin"})
  assert(x:check())
  local T = x:reincarnate()

  local expected_op = [[lVector ( { qtype = "I4", file_name = "_in1_I4.bin", nn_file_name = "_nn_in1.bin",  } ) ]]
  assert(T == expected_op)
  -- cannot call reincarnate on nascent vector
  x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  T = x:reincarnate()
  assert(T == nil)
  print("Successfully completed test t1")
end
---- =========

return tests
