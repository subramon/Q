local plpath = require 'pl.path'
local plfile = require 'pl.file'
local plutils= require 'pl.utils'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'
local lgutils = require 'liblgutils'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
--=======================================================
local tests = {}
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "str", qtype = "SC", has_nulls = false, width = 16}
  local datafile = qcfg.q_src_root .. 
    "/OPERATORS/F1S1OPF2/test/input_vstrcmp.csv"
  assert(plpath.isfile(datafile), "File not found " .. datafile)
  local T = Q.load_csv(datafile, M, O)
  local x = Q.vstrcmp(T.str, "abc")
  assert(type(x) == "lVector")
  assert(x:qtype() == "BL")
  assert(x:has_nulls() == false)
  local r = Q.sum(x)
  assert(type(r) == "Reducer")
  local n1, n2 = r:eval()
  assert(type(n1) == "Scalar")
  assert(n1:to_num() == 2)
  assert(n2:to_num() == 10)
  --===================
  assert(cVector.check_all())
  T = nil; r = nil
  print("Test t1 succeeded")
end
tests.t1()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
