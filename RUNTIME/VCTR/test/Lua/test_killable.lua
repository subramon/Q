local Q = require 'Q'
local cVector = require 'libvctr'
local qcfg = require 'Q/UTILS/lua/qcfg'
local lgutils = require 'liblgutils'

local len = 2 * qcfg.max_num_in_chunk + 17
local tests = {}
tests.t1 = function()
  local pre = lgutils.mem_used()
  -- set bad value and see if it is caught
  local status = pcall(qcfg._modify, "killable", 
    { "foo bar", 1000})
  assert(not status)
  local status = pcall(qcfg._modify, "killable",
    { false, 1 })
  assert(not status)
  local status = pcall(qcfg._modify, "killable",
    { true, -1 })
  assert(not status)
  -- set good value and see if it is reflected
  local status, msg = pcall(qcfg._modify, "killable",
    { true, 1 })
  assert(status)
  local x = Q.seq({start = 1, by = 1, len = len, qtype = "I4"}):set_name("x")
  local b_is_killable, num_kill_ignore = x:get_killable()
  assert(b_is_killable == true)
  assert(num_kill_ignore == 1)
  -- set good value and see if it is reflected
  local status = pcall(qcfg._modify, "killable", { false, 0 })
  assert(status)
  local y = Q.seq({start = 1, by = 1, len = len, qtype = "I4"}):set_name("y")
  local b_is_killable, num_kill_ignore = y:get_killable()
  assert(b_is_killable == false)
  assert(num_kill_ignore == 0)
  -- This set should work 
  assert(y:set_killable(10))
  local b_is_killable, num_kill_ignore = y:get_killable()
  assert(b_is_killable == true)
  assert(num_kill_ignore == 10)

  local z = Q.vvadd(x, y):eval()
  assert(cVector.check_all())

  assert(y:num_elements() == len); 
  assert(z:num_elements() == len); 

  x:delete()
  y:delete()
  z:delete()
  assert(cVector.check_all())
  local post = lgutils.mem_used()
  assert(pre == post)
  print("Test t1 succeeded")
end
tests.t1()
-- return tests
