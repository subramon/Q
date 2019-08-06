local lVector = require 'Q/RUNTIME/lua/lVector'
local ffi = require 'ffi'
local qc     = require 'Q/UTILS/lua/q_core'
require 'Q/UTILS/lua/strict'

local tests = {} 

tests.t1 = function()
  local num_elements = 10
  local qtype = "B1"
  -- generating required .bin file for B1 materialized vector
  qc.generate_bin(num_elements, qtype, "_nn_in2.bin", nil )
  
  local x = lVector( { qtype = qtype, file_name = "_nn_in2.bin", num_elements = num_elements} )
  assert(x:check())
  local len, base_data, nn_data = x:get_all()
  assert(base_data)
  --assert(nn_data)
  assert(len == num_elements)
  local base_data_u = ffi.cast("char *", base_data)
  print(base_data_u[0])
  print(base_data_u[1])
  print("Successfully completed test t1")
end

return tests
