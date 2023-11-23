local plpath = require 'pl.path'
local plfile = require 'pl.file'
local plutils= require 'pl.utils'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'
local lgutils = require 'liblgutils'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local cVector = require 'libvctr'
--=======================================================
local tests = {}
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "str", qtype = "SC", has_nulls = false, width = 16}
  local datafile = qcfg.q_src_root .. 
    "/OPERATORS/F1S1OPF2/test/input_vstrcmp.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  local x = Q.vstrcmp(T.str, "ABC")
  assert(type(x) == "lVector")
  assert(x:qtype() == "BL")
  assert(x:has_nulls() == false)
  x:eval()
  assert(x:num_elements() == T.str_date:num_elements())
  x:pr("_3", 0, 0, format); 
  local chkfile1 = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/output_1_SC_to_TM1.csv"
  assert(diff("_3", chkfile1))
  --===================
  if ( test_print ) then
    local opfile = "_4"
    local U = {}
    U[1] = T.str_date
    U[2] = x
    Q.print_csv(U, 
    { opfile = opfile, impl = "C", header = "str_date,x", })
    local chkfile2 = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/output_2_SC_to_TM1.csv"
    assert(diff("_4", chkfile2))
  end
  cVector:check_all(true, true)
  --===================
  assert(cVector.check_all())
  print("Test t1 succeeded")
end
tests.t0 = function()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "datetime", qtype = "SC", has_nulls = false, width=20}
  local format = "%Y-%m-%d"
  local datafile = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/input_SC_to_TM1.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  print("Test t0 succeeded")
end
-- test when input SC has nulls in it 
tests.t2 = function()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "str_date", qtype = "SC", has_nulls = true, width=20}
  local format = "%Y-%m-%d"
  local datafile = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/nn_input_SC_to_TM1.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  local x = Q.SC_to_TM(T.str_date, format, { out_qtype = "TM1" })
  assert(type(x) == "lVector")
  x:eval()
  -- print and check
  plfile.delete("_x")
  Q.print_csv({T.str_date, x}, 
    { opfile = "_x", impl = "C", header = "str_date,x", })
  local chkfile = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/output_nn_SC_to_TM1.csv"
  assert(diff("_x", chkfile))
  print("Test t2 succeeded")
  -- Convert to TM1
end
tests.t0()
tests.t1()
tests.t2()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
