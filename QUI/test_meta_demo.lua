-- create global vectors
local Q = require 'Q'

local tests = {}

tests.t1 = function()
  a = Q.mk_col({1, 2, 3, 4, 5}, "I4")
  b = Q.mk_col({1, 3,  5}, "I4")
  c = Q.mk_col({2, 4}, "I4")
  d = Q.mk_col({1, 3, 5}, "I4")
  e = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")

  local meta_table, meta_json = Q.view_meta()
  assert(type(meta_table) == "table")
  assert(meta_json)
  print(meta_json)
end

return tests
