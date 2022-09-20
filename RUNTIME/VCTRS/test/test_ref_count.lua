local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qcfg = require 'Q/UTILS/lua/qcfg'
local tests = {}
tests.t1 = function()
  local x = lVector({ qtype = "F4", width = 4})
  assert(x:ref_count() == 1)
  local x_uqid = x:uqid()
  assert(x_uqid == 1)
  local y = lVector({uqid = x_uqid})
  assert(type(y) == "lVector")
  local y_uqid = y:uqid()
  print(y_uqid, x_uqid)
  assert(y_uqid == x_uqid)
  assert(y:ref_count() == 2)
  x = nil
  collectgarbage()
  assert(y:ref_count() == 1)
end
-- return tests
tests.t1()
