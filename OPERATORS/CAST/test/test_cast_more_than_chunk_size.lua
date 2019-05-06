-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/OPERATORS/CAST/test/"
assert(plpath.isdir(path_to_here))
local tests = {}

-- testing cast operator for num_elements more than chunk_size
tests.t1 = function ()
--=============================
  local input_table = {}
  for i = 1, 65540 do
    input_table[i] = i * 10
  end
  
  local col1 = Q.mk_col(input_table, "I8")
  local sum1 = Q.sum(col1):eval():to_num()
  local col2 = Q.cast(col1, "I4")
  -- Q.print_csv(col2, { opfile = path_to_here .. "print_I4_casted_data.csv" })
  assert(col1:qtype() == "I4")
  assert(col2:qtype() == "I4")
  assert(col2:num_elements() == 131080)
  local sum2 = Q.sum(col2):eval():to_num()
  assert(sum1 == sum2)
  
end

return tests
