local Q = require 'Q'
local cVector = require 'libvctr'
local qcfg = require 'Q/UTILS/lua/qcfg'
local lgutils = require 'liblgutils'

local len = 2 * qcfg.max_num_in_chunk + 17
local tests = {}
tests.t1 = function()
  local pre = lgutils.mem_used()
  -- set bad value and see if it is caught
  local status = pcall(qcfg._modify, "num_lives_kill", -1)
  assert(not status)
  local status = pcall(qcfg._modify, "num_lives_kill", 1000)
  assert(not status)
  -- set good value and see if it is reflected
  local status = pcall(qcfg._modify, "num_lives_kill", 1)
  assert(status)
  local x = Q.seq({start = 1, by = 1, len = len, qtype = "I4"}):set_name("x")
  local b_is_killable, num_lives_kill = x:is_killable()
  assert(b_is_killable == true)
  assert(num_lives_kill == 1)
  -- set good value and see if it is reflected
  local status = pcall(qcfg._modify, "num_lives_kill", 0)
  assert(status)
  print("XXXXXXX")
  local y = Q.seq({start = 1, by = 1, len = len, qtype = "I4"}):set_name("y")
  local b_is_killable, num_lives_kill = y:is_killable()
  assert(b_is_killable == false)
  assert(num_lives_kill == 0)
  -- try to unset after set, should not work 

  local z = Q.vvadd(x, y):eval()
  assert(cVector.check_all())
  print(">>>> START DELIBERATE ERROR")
  assert(x:num_elements() == nil); x:delete()
  print("<<<< STOP  DELIBERATE ERROR")

  assert(y:num_elements() == len); 
  assert(z:num_elements() == len); 

  y:delete()
  z:delete()
  assert(cVector.check_all())
  local post = lgutils.mem_used()
  assert(pre == post)
  print("Test t1 succeeded")
end
tests.t1()
-- return tests
