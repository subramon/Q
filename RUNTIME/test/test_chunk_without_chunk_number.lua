local Q = require 'Q'

local tests = {}

tests.t1 = function()
  local input_table = {}
  for i=1, 65536 do
    input_table[i] = 1
  end
  input_table[65537] = 0
  input_table[65538] = 1
  local b = Q.mk_col(input_table, "I1")
  local metadata = b:meta()
  assert(metadata.base.is_nascent == true)
  assert(metadata.base.is_eov == true)
  local len, base_data, nn_data = b:get_all()
  -- print("Length: " .. len)
  assert(len == 65538)
end

return tests
