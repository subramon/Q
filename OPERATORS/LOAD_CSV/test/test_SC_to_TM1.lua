local plpath = require 'pl.path'
local plutils= require 'pl.utils'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local cVector = require 'libvctr'
-- Set below to true if you want printing 
local test_print  = true -- turn false if you want only load_csv tested
--=======================================================
local function diff(x, y)
  local s1 = assert(plutils.readfile(x))
  local s2 = assert(plutils.readfile(y))
  if ( s1 == s2 ) then 
    return true 
  else 
    print("Mismatch between " .. x .. " and " .. y)
    return false 
  end
end
local tests = {}
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "datetime", qtype = "SC", has_nulls = false, width=20}
  local format = "%Y-%m-%d"
  local datafile = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/input_SC_to_TM1.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  T.datetime:eval()
  T.datetime:pr("_1", 0, 0, format); 
  local x = Q.SC_to_TM(T.datetime, format, { out_qtype = "TM1" })
  assert(type(x) == "lVector")
  x:eval()
  assert(x:num_elements() == T.datetime:num_elements())
  x:pr("_3", 0, 0, format); 
  local chkfile1 = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/output_1_SC_to_TM1.csv"
  assert(diff("_3", chkfile1))
  --===================
  if ( test_print ) then
    local opfile = "_4"
    local U = {}
    U[1] = T.datetime
    U[2] = x
    Q.print_csv(U, 
    { opfile = opfile, impl = "C", header = "datetime,x", })
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
  print("Test t1 succeeded")
end
tests.t0()
-- WORKS tests.t1()
os.exit()
--[[
return tests
--]]
