-- FUNCTIONAL
local plfile = require 'pl.file'
require 'Q/UTILS/lua/strict'
local qcfg = require 'Q/UTILS/lua/qcfg'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'

local tests = {}
tests.t1 = function()
  local ys = {"abc", "defg", "hijkl"}
  local x = mk_col(ys, "SC")
  assert(x:num_elements() == #ys)
  assert(x:qtype() == "SC")
  assert(x:width() == 6) -- strlen("hijkl") + 1 
  for i, y in ipairs(ys) do 
    local s = x:get1(i-1)
    assert(type(s) == "Scalar")
    assert(s:to_str("SC") == y)
  end
  x:eov()
  x:pr("_x")
  local str1 = plfile.read("_x")
  local chkfile = 
    qcfg.q_src_root .. "/OPERATORS/MK_COL/test/" ..  "test_mkcol_SC_out.csv"
  local str1 = plfile.read("_x")
  local str2 = plfile.read(chkfile)
  assert(str1 == str2)
  print("Test t1 succeeded")
end
-- return tests
tests.t1()
