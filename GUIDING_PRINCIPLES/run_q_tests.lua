local PROG = {}

PROG.PROG_START = function()
  local q_core    = require 'Q/UTILS/lua/q_core'
  local q_consts  = require 'Q/UTILS/lua/q_consts'
  local load_csv  = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
  local print_csv = require 'Q/OPERATORS/PRINT/lua/print_csv'
  local mk_col    = require 'Q/OPERATORS/MK_COL/lua/mk_col'
  local save      = require 'Q/UTILS/lua/save'
end

PROG.PROG_SAVE = function()
  local q_core = require 'Q/UTILS/lua/q_core'
  local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
  local save   = require 'Q/UTILS/lua/save'
  x = mk_col({10, 20, 30, 40}, 'I4')
  print(type(x))
  print(x:length())
  save('/tmp/tmp.save')
end

PROG.PROG_RESTORE = function()
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local restore = require 'Q/UTILS/lua/restore'
  local status, ret = pcall(restore, "/tmp/tmp.save")
  assert(status, ret)
  print(type(x))
  print(x:length())
  assert(type(x) == "lVector")
  assert(x:length() == 4)
  print_csv = require 'Q/OPERATORS/PRINT/lua/print_csv'
  print_csv(x)
end

local run_q_tests = function()
  -- performance test stretch goal - add
  local RES = pcall(PROG.PROG_START)
  if RES == true then
    os.execute("bash my_print.sh \"SUCCESS in loading all libs\"")
  else
    os.execute("bash my_print.sh \"FAIL error\"")
  end

  RES = pcall(PROG.PROG_SAVE)
  if RES == true then
    os.execute("bash my_print.sh \"SUCCESS in saving\"")
  else
    os.execute("bash my_print.sh \"FAIL error\"")
  end

  RES = pcall(PROG.PROG_RESTORE)
  if RES == true then
    os.execute("bash my_print.sh \"SUCCESS in restoring\"")
  else
    os.execute("bash my_print.sh \"FAIL error\"")
  end
end

return run_q_tests
