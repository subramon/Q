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
  local pre = lgutils.mem_used()
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
  local optargs = {}
  for _, impl in ipairs({"Lua", "C"}) do 
    optargs.impl = impl
    for _, qtype in ipairs({"I1", "I2", "I4", }) do 
      optargs.out_qtype = qtype 
      local lkp = Q.SC_to_lkp(T.txt, lkp_tbl, optargs):set_name("lkp_out")
      assert(type(lkp) == "lVector")
      assert(lkp:qtype() == qtype)
      assert(lkp:has_nulls())
      lkp:eval()
      -- lkp:pr()
      local nn = lkp:get_nulls()
      lkp:drop_nulls() -- sum() needs to accept nulls 
      nn:delete()
      local tmp = Q.vveq(lkp, T.idx):set_name("tmp")
      local r = Q.sum(tmp)
      local n1, n2 = r:eval()
      assert(n1 == n2)
      -- clenup
      tmp:delete()
      lkp:delete()
      r:delete()
      print("Success for impl/qtype = ", impl, qtype)
    end
  end
  print("Automate checking of results")
  --==================
  -- T.txt:eval()
  cVector.check_all()
  T.txt:delete()
  T.idx:delete()
  --==================
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
  print("Successfully completed test t1 ")
end
tests.t1()
