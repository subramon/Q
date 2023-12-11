local cutils = require 'libcutils'
local plutils= require 'pl.utils'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils  = require 'liblgutils'
--=======================================================
local tests = {}
tests.t1 = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local M = {}
  local O = { is_hdr = true }
  -- TODO P1 Test with different memo_len values 
  M[#M+1] = { name = "idx", qtype = "I4", has_nulls = false, }
  M[#M+1] = { name = "txt", qtype = "SC", width= 8, has_nulls = true, }
  local datafile = qcfg.q_src_root .. 
  "/OPERATORS/LOAD_CSV/test/test_SC_to_lkp.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  --==================
  local lkp_tbl = { "A", "AB", "ABC", "ABCD", "ABCDE", }
  local lkp = Q.SC_to_lkp(T.txt, lkp_tbl)
  assert(type(lkp) == "lVector")
  assert(lkp:qtype() == "I1")
  assert(lkp:has_nulls())
  lkp:eval()
  lkp:pr()
  print("Automate checking of results")
  --==================
  T.txt:eval()
  cVector.check_all()
  T.txt:delete()
  T.idx:delete()
  lkp:delete()
  --==================
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  collectgarbage("restart")
  print("Successfully completed test t1 ")
end
tests.t1()
