-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local max_num_in_chunk = qcfg.max_num_in_chunk

local tests = {}
tests.t1 = function()
  local len =  2*64 + 17
  local T1 = {}; local val1 = 1
  local T2 = {}; local val2 = 0
  for i = 1, len do 
    T1[i] = val1; if ( val1 == 0 ) then val1 = 1 else val1 = 0 end 
    T2[i] = val2; if ( val2 == 0 ) then val2 = 1 else val2 = 0 end 
  end
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8"}) do
    local c1 = Q.mk_col(T1, qtype)
    local c2 = Q.mk_col(T2, qtype)
    assert(c1:num_elements() == len)
    assert(c2:num_elements() == len)
    -- Q.print_csv({c1, c2})
    local c3 = Q.vveq(c1, c2)
    local n1, n2 = Q.sum(c3):eval()
    assert(n1 == Scalar.new(0))

    local c3 = Q.vveq(c1, c1)
    local n1, n2 = Q.sum(c3):eval()
    assert(n1 == n2)
  end
  assert(cVector.check_all())
  print("Test t1 succeeded")
end
tests.t2 = function()
  local len =  2*max_num_in_chunk + 17
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8"}) do
    local c1 = Q.const({ val = 1, len = len, qtype = qtype, 
      max_num_in_chunk = max_num_in_chunk} )
    local c3 = Q.vveq(c1, c1)
    local n1, n2 = Q.sum(c3):eval()
    local n1, n2 = Q.sum(c3):eval()
    assert(n1 == n2)
  end
  assert(cVector.check_all())
  print("Test t2 succeeded")
end
tests.t3 = function()
  local len =  2*max_num_in_chunk + 17
  local c1 = lVector.new({ qtype = "I1", max_num_in_chunk = max_num_in_chunk })
  local c2 = lVector.new({ qtype = "I1", max_num_in_chunk = max_num_in_chunk })
  for i = 1, len do 
    c1:put1(Scalar.new(1, "I1"))
    c2:put1(Scalar.new(0, "I1"))
  end
  c1:eov()
  c2:eov()

  local c3 = Q.vveq(c1, c1)
  local n1, n2 = Q.sum(c3):eval()
  assert(n1 == n2)

  local c3 = Q.vveq(c1, c2)
  local n1, n2 = Q.sum(c3):eval()
  assert(n1 == Scalar.new(0))
  assert(cVector.check_all())
  print("Test t3 succeeded")
end
-- return tests
tests.t1()
tests.t2()
tests.t3()
os.exit()
