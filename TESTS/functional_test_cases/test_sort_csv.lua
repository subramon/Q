-- Test sort behaviour of Q with load csv
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- TEST SORT TWICE: DSC & ASC
  local meta = {
   { name = "empid", has_nulls = true, qtype = "I4", is_load = true }
  }
  local datadir = os.getenv("Q_SRC_ROOT") .. "/TESTS/functional_test_cases/"
  local x = Q.load_csv(datadir .. "I4.csv", meta)
  assert(type(x) == "table")
  for i, v in pairs(x) do
    local y = x[i]
    assert(type(y) == "lVector")
    -- Desc & Asc = Asc
    Q.sort(y, "dsc")
    Q.sort(y, "asc")
    local z = Q.mk_col({10,20,30,40,50}, 'I4')
    assert(type(z) == "lVector")
    local p = Q.vveq(y, z)
    assert(type(p) == "lVector")
    assert(Q.sum(p):eval():to_num() == y:length())
  end
end

--======================================

tests.t2 = function ()
  -- TEST SORT TWICE: ASC & DSC
  local meta = {
    { name = "empid", has_nulls = true, qtype = "I4", is_load = true }
  }
  local datadir = os.getenv("Q_SRC_ROOT") .. "/TESTS/functional_test_cases/"
  local x = Q.load_csv(datadir .. "I4.csv", meta)
  assert(type(x) == "table")
  for i, v in pairs(x) do
    local y = x[i]
    assert(type(y) == "lVector")
    -- Asc & Dsc = Dsc
    Q.sort(y, "asc")
    Q.sort(y, "dsc")
    local z = Q.mk_col({50,40,30,20,10}, 'I4')
    assert(type(z) == "lVector")
    local p = Q.vveq(y, z)
    assert(type(p) == "lVector")
    assert(Q.sum(p):eval():to_num() == y:length())
  end
end

--=======================================

return tests
