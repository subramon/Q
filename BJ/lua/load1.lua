local cutils = require 'libcutils'
local plutils= require 'pl.utils'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
--=======================================================
local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
-- TODO P2 For optimization, set memo_len = 1 for effective_d, expiry_d
local function load1()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "tcin", qtype = "I4", has_nulls = false, memo_len = -1 }
  M[#M+1] = { name = "location_id", qtype = "I4", has_nulls = false, memo_len = -1  }
  M[#M+1] = { name = "effective_d", qtype = "SC", width = 12, has_nulls = false, memo_len = -1  }
  M[#M+1] = { name = "expiry_d", qtype = "SC", width = 12, has_nulls = true, memo_len = -1  }
  M[#M+1] = { name = "regular_retail_a", qtype = "F4", has_nulls = false, memo_len = -1  }
  M[#M+1] = { name = "current_retail_a", qtype = "F4", has_nulls = false, memo_len = -1  }
  M[#M+1] = { name = "channel_n", qtype = "SC", width = 8, has_nulls = false, memo_len = -1  }
  local datafile = qcfg.q_src_root .. "/BJ/data/price_cds_dump.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(T) == "table")
  assert(type(T.tcin) == "lVector")
  -- convert SC to TM
  local format = "%Y-%m-%d"
  T.effective_tm = Q.SC_to_TM(T.effective_d, format, { out_qtype = "TM1" })
  T.expiry_tm = Q.SC_to_TM(T.expiry_d, format, { out_qtype = "TM1" })
  return T
end
return load1
