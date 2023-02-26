-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local lgutils = require 'liblgutils'

local tests = {}
tests.t1 = function( to_memo)
  if ( type(to_memo) == "nil" ) then to_memo = false end 

  local max_num_in_chunk = 64 
  local len = 2 * max_num_in_chunk + 17
  local x, y, z 
  local qtype = "I4"
  local c1 = Q.seq({start = 1, by = 1, len = len, qtype = qtype})

  local ops ={ "sum", "min", "max" }
  local T  = Q.fold({ "sum", "min", "max" }, c1)
  for _, op in pairs(ops) do 
    local tt = assert(T[op])
    assert(type(tt) == "table")
    for k, v in pairs(tt) do 
      assert(type(tt[1]) == "Scalar")
      assert(type(tt[2]) == "Scalar")
      if ( tt[3] ) then 
        assert(type(tt[3]) == "Scalar")
      end
    end
  end
  -- for comparison
  local d1 = Q.seq({start = 1, by = 1, len = len, qtype = qtype})
  local sum_rdcr = Q.sum(d1)
  local min_rdcr = Q.min(d1)
  local max_rdcr = Q.max(d1)
  local sumval, sumnum          = sum_rdcr:eval()
  local minval, minnum, minidx  = min_rdcr:eval()
  local maxval, maxnum, maxidx  = max_rdcr:eval()

  assert(T["sum"][1] == sumval)
  assert(T["sum"][2] == sumnum)

  assert(T["min"][1] == minval)
  assert(T["min"][2] == minnum)

  assert(T["max"][1] == maxval)
  assert(T["max"][2] == maxnum)

  assert(cVector.check_all())
  c1:delete()
  d1:delete()
  sum_rdcr:delete()
  min_rdcr:delete()
  max_rdcr:delete()
  print("Test t1 succeeded")
  return true
end
tests.t2 = function()
  assert(tests.t1(true))
  assert(tests.t1(false))
  assert(cVector.check_all())
  print("Test t2 succeeded")
  return true
end
tests.t1()
tests.t2()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
