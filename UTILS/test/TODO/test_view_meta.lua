local Q = require 'Q'
--require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local c1 = Q.mk_col({1, 2, 3, 4, 5}, "I4")
  c1:set_name("first_vec")
  local meta_table, meta_json = Q.view_meta()
  assert(type(meta_table) == "table")
  assert(meta_json)
  print(meta_json)
end

return tests
