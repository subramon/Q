local tests = {}
local Q = require 'Q'

tests.t1 = function()
  local input_vector = Q.mk_col( {1,2,2,3,3,3,4,5,6,7,8,9,9,9,10}, "I1")
  local status, order = Q.is_sorted(input_vector)
  assert(status == true)
  assert(order == "asc")
  print("successfully executed t1")
end

tests.t2 = function()
  local input_vector = Q.mk_col( {10,9,9,9,8,7,6,5,4,3,3,3,2,2,1}, "I1")
  local status, order = Q.is_sorted(input_vector)
  assert(status == true)
  assert(order == "dsc")
  print("successfully executed t2")
end

tests.t3 = function()
  local input_vector = Q.mk_col( {1,5,2,4,10,3,6,8}, "I1")
  local status, order = Q.is_sorted(input_vector)
  assert(status == false)
  assert(order == nil)
  print("successfully executed t3")
end
return tests
