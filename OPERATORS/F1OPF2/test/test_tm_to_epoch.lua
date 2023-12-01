local cutils = require 'libcutils'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils  = require 'liblgutils'

local tests = {}
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "datetime", qtype = "SC", has_nulls = false, width=20}
  local format = "%Y-%m-%d %H:%M:%S"
  local datafile = qcfg.q_src_root .. "/OPERATORS/F1OPF2/test/tm1.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(T.datetime) == "lVector")
  cVector.check_all(true, true)
  local x = Q.SC_to_TM(T.datetime, format, { out_qtype = "TM1"})
  assert(type(x) == "lVector")
  -- x:eval(); x:pr()


  local y = Q.tm_to_epoch(x):eval()
  y:pr()
  local chk_y = Q.seq({start = 1493629200, by = 86400, 
    len = y:num_elements(), qtype = y:qtype(), })
  local n1, n2 = Q.sum(Q.vveq(y, chk_y)):eval()
  assert(n1 == n2)
  
  print("Test t1 succeeded")
end
tests.t1()
-- return tests
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
