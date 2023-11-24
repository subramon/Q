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
local KeyCounter = require 'Q/RUNTIME/CNTR/lua/KeyCounter'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils  = require 'liblgutils'
--=======================================================
local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
local tests = {}
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  -- TODO P1 Test with different memo_len values 
  M[#M+1] = { name = "tcin", qtype = "I4", has_nulls = false, memo_len = -1 }
  M[#M+1] = { name = "location_id", qtype = "I4", has_nulls = false, memo_len = -1  }
  M[#M+1] = { name = "effective_d", qtype = "SC", width = 12, has_nulls = false, memo_len = -1  }
  M[#M+1] = { name = "expiry_d", qtype = "SC", width = 12, has_nulls = true, memo_len = -1  }
  M[#M+1] = { name = "regular_retail_a", qtype = "F4", has_nulls = false, memo_len = -1  }
  M[#M+1] = { name = "current_retail_a", qtype = "F4", has_nulls = false, memo_len = -1  }
  M[#M+1] = { name = "channel", qtype = "SC", width = 8, has_nulls = false, memo_len = -1  }
  local datafile = qcfg.q_src_root .. "/BJ/data/price_cds_dump.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(T) == "table")
  assert(type(T.tcin) == "lVector")
  -- convert SC to TM
  local format = "%Y-%m-%d"
  local effective_tm = Q.SC_to_TM(T.effective_d, format, { out_qtype = "TM1" })
  local expiry_tm = Q.SC_to_TM(T.expiry_d, format, { out_qtype = "TM1" })
  -- mark rows for deletion
  local x1 = Q.vstrcmp(T.channel, "STORE")
  -- create composite pk
  local pk = Q.concat(T.tcin, T.location_id)
  assert(type(pk) == "lVector")
  assert(pk:qtype() == "I8")
  -- cleanup
  for k, v in pairs(T) do v:delete() end; T = nil ; 
  pk = nil
  assert(cVector.check_all())
  collectgarbage()
  print("MEM", lgutils.mem_used())
  print("DSK", lgutils.dsk_used())
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  print("Test t1 succeeded")
end
tests.t1()
-- return tests
