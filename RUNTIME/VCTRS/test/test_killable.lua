local Q = require 'Q'
local cVector = require 'libvctr'
local qcfg = require 'Q/UTILS/lua/qcfg'
local lgutils = require 'liblgutils'

local len = 2 * qcfg.max_num_in_chunk + 17
local tests = {}
tests.t1 = function()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  qcfg._modify("is_killable", true)
  print("XXX", qcfg.is_killable)
  local x = Q.seq({start = 1, by = 1, len = len, qtype = "I4"}):set_name("x")
  assert(x:is_killable() == true)
  qcfg._modify("is_killable", false)
  local y = Q.seq({start = 1, by = 1, len = len, qtype = "I4"}):set_name("y")
  assert(y:is_killable() == false)
  local z = Q.vvadd(x, y):eval()
  cVector.check_all()
  print(">>>> START DELIBERATE ERROR")
  assert(x:num_elements() == nil); x:delete()
  print("<<<< STOP  DELIBERATE ERROR")
  assert(y:num_elements() == len); y:delete()
  assert(z:num_elements() == len); z:delete()
  cVector.check_all()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  print("Test t1 succeeded")
end
tests.t1()
-- return tests
