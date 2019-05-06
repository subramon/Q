local Q = require 'Q'

local tests = {}

tests.t1 = function()
  local col = Q.mk_col({1, 2, 3, 4}, "I2")
  print("==========Before Delete=========")
  assert(col:file_size() == 8)
  print("File size = " .. col:file_size())
  assert(col:num_elements() == 4)
  print("Num elements = " .. col:num_elements())
  assert(col:file_name())
  print("File name = " .. col:file_name())

  local status = col:delete()
  print("==========After Delete=========")
  assert(col:file_size() == 0)
  print("File size = " .. col:file_size())
  assert(col:num_elements() == 0)
  print("Num elements = " .. col:num_elements())
  assert(col:file_name() == "")
  print("File name = " .. col:file_name())

  assert(status == true)
  print("Successfully executed t1")
end

return tests
