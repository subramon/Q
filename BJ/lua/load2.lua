local cutils = require 'libcutils'
local plutils= require 'pl.utils'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
--=======================================================
local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
local function load2()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "tcin", qtype = "I4", has_nulls = false, memo_len = -1 }
  M[#M+1] = { name = "location_id", qtype = "I4", has_nulls = false, memo_len = -1  }
  M[#M+1] = { name = "item_location_status_c", qtype = "SC", width = 4, has_nulls = false, memo_len = -1  }
  local datafile = qcfg.q_src_root .. "/BJ/data/ils_cds_dump.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(T) == "table")
  assert(type(T.tcin) == "lVector")
  return T
end
return load2
