-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local cutils  = require 'libcutils'
local cVector = require 'libvctr'
local plpath  = require 'pl.path'
local plfile  = require 'pl.file'
local qcfg    = require 'Q/UTILS/lua/qcfg'

local max_num_in_chunk = qcfg.max_num_in_chunk

-- validating unique operator to return unique values from input vector
-- FUNCTIONAL
-- where num_elements are less than max_num_in_chunk
local tests = {}
tests.t1 = function()
  local O = { is_hdr = true, max_num_in_chunk = 64  }
  -- load source data 
  local M = {}
  M[#M+1] = { name = "src_lnk", qtype = "I4", has_nulls = false, }
  M[#M+1] = { name = "src_val", qtype = "I4", has_nulls = false, }
  local datafile = qcfg.q_src_root ..  "/OPERATORS/JOIN/test/join_src_2.csv"
  assert(plpath.isfile(datafile))
  local Tsrc = Q.load_csv(datafile, M, O)
  assert(Tsrc.src_lnk:max_num_in_chunk() == 64)
    -- load destination data 
  local M = {}
  M[#M+1] = { name = "dst_lnk", qtype = "I4", has_nulls = false, }
  M[#M+1] = { name = "dst_cnt", qtype = "I4", has_nulls = false, }
  M[#M+1] = { name = "dst_min", qtype = "I4", has_nulls = false, }
  M[#M+1] = { name = "dst_max", qtype = "I4", has_nulls = false, }
  local datafile = qcfg.q_src_root ..  "/OPERATORS/JOIN/test/join_dst_2.csv"
  assert(plpath.isfile(datafile))
  local Tdst = Q.load_csv(datafile, M, O)
  assert(Tdst.dst_lnk:max_num_in_chunk() == 64)
  --==============================================
  local join_types = { "cnt", "min", "max", }
  local T = Q.join(Tsrc.src_val, Tsrc.src_lnk, Tdst.dst_lnk, join_types)
  T.cnt:eval()
  -- checking 
  assert(not Tdst.dst_cnt:has_nulls())
  local n1, n2 = Q.sum(Q.vveq(T.cnt, Tdst.dst_cnt)):eval()
  assert(n1 == n2)
  --====================================================
  assert(type(T.min) == "lVector")
  assert(T.min:has_nulls())
  local x = T.min:get_nulls()
  local n1, n2 = Q.sum(x):eval()

  assert(n1 == n2)
  local n1, n2 = Q.sum(Q.vveq(T.min, Tdst.dst_min)):eval()
  assert(n1 == n2)
  --====================================================
  assert(type(T.max) == "lVector")
  assert(T.max:has_nulls())
  local x = T.max:get_nulls()
  local n1, n2 = Q.sum(x):eval()
  assert(n1 == n2)
  local n1, n2 = Q.sum(Q.vveq(T.max, Tdst.dst_max)):eval()
  assert(n1 == n2)
  print("Test t1 succeeded")
  -- error("PREMATURE")
end
tests.t1()
-- return tests
