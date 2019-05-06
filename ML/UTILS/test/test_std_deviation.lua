local std_deviation_score = require 'Q/ML/UTILS/lua/ml_utils'['std_deviation_score']

local tests = {}

tests.t1 = function()
  local in_list = {2, 4, 6, 8, 10, 12}
  local exp_result = 3.4156502553199
  local std_deviation = std_deviation_score(in_list)
  assert(tostring(std_deviation) == tostring(exp_result))
  print("completed test t1")
end

return tests
