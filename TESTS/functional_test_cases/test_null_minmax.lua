-- Test to check min & max of a null vector
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local datadir = os.getenv("Q_SRC_ROOT") .. "/TESTS/functional_test_cases/"
local tests = {}
tests.t1 = function ()
  -- TEST MIN MAX WITH SORT
  local meta = {
    { name = "cd", has_nulls = true, qtype = "I2", is_load = true }
  }

  local x = Q.load_csv(datadir .. "I4_null.csv", meta)
  assert(type(x) == "table")
  for i, v in pairs(x) do
    local y = x[i]
    assert(type(y) == "lVector")
    -- find min & max
    local z = Q.min(y)
    local status = true repeat status = z:next() until not status
    local val = z:value()
    assert(val:to_num() == 0 )
    assert(Q.min(y):eval():to_num() == 0)
    local min = Q.min(y):eval():to_num()
    local z = Q.max(y)
    local status = true repeat status = z:next() until not status
    local val = z:value()
    assert(val:to_num() == 0 )
    assert(Q.max(y):eval():to_num() == 0)
    local max = Q.max(y):eval():to_num()
    assert(min == max, "Value mismatch in the case of min & max of a null vector")
  end
end

--======================================
                                
return tests

