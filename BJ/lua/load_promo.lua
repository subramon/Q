local cutils = require 'libcutils'
local plutils= require 'pl.utils'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
--=======================================================
local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
local function load_promo()
  local M = {}
  local O = { is_hdr = false }
  M[#M+1] = { name = "promotion_id", qtype = "I4", has_nulls = false, memo_len = -1 }
  M[#M+1] = { name = "promotion_start_ct_ts", qtype = "SC", width = 24, has_nulls = false, memo_len = 1  }
  M[#M+1] = { name = "promotion_end_ct_ts", qtype = "SC", width = 24, has_nulls = false, memo_len = 1  }
  M[#M+1] = { name = "promotion_status", qtype = "SC", width = 16, has_nulls = false, memo_len = 1  }
  M[#M+1] = { name = "promotion_channel", qtype = "SC", width = 24, has_nulls = true, memo_len = 1  }
  M[#M+1] = { name = "promotion_vehicle", qtype = "SC", width = 24, has_nulls = true, memo_len = 1  }
  M[#M+1] = { name = "promotion_type", qtype = "SC", width = 24, has_nulls = false, memo_len = 1  }
  M[#M+1] = { name = "mofidified_ct_ts", qtype = "SC", width = 24, has_nulls = false, memo_len = 1  }
  M[#M+1] = { name = "visibility_rank", qtype = "I2", has_nulls = true, memo_len = -1  }
  M[#M+1] = { name = "finance_type", qtype = "I1", has_nulls = true, memo_len = -1  }
  M[#M+1] = { name = "partition_key", qtype = "I4", has_nulls = false, memo_len = -1  }
  local datafile = qcfg.q_src_root .. "/BJ/data/promo.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(T) == "table")
  assert(type(T.promotion_id) == "lVector")
  --[[
1 promotion_id,
2 promotion_start_ct_ts,
3 promotion_end_ct_ts,
4 promotion_status, 
5 promotion_channel, 
6 promotion_vehicle, 
7 promotion_type,
8 modified_ct_ts, 
9 visibility_rank, 
10 finance_type, 
11 partition_key
  --]]
  -- START: conversions to be done 
  local format = "%Y-%m-%d %H-%M-%S"
  T.promo_start_tm = Q.SC_to_TM(T.promotion_start_ct_ts, 
    format, { out_qtype = "TM1" }):set_name("promo_start_tm"):memo(1)
  T.promo_end_tm = Q.SC_to_TM(T.promotion_end_ct_ts, 
    format, { out_qtype = "TM1" }):set_name("promo_end_tm"):memo(1)
  T.promo_mod_tm = Q.SC_to_TM(T.modified_end_ct_ts, 
    format, { out_qtype = "TM1" }):set_name("promo_mod_tm"):memo(1)
  --====================================
  T.promo_start = Q.tm_to_epoch(T1.promo_start_tm):set_name("promo_start")
  T.promo_end = Q.tm_to_epoch(T1.promo_end_tm):set_name("promo_end")
  T.promo_mod = Q.tm_to_epoch(T1.promo_mod_tm):set_name("promo_mod")
  --====================================
  local promo_status_lkp = require 'promo_status_lkp'
  local promo_channel_lkp = require 'promo_channel_lkp'
  local promo_vehicle_lkp = require 'promo_vehicle_lkp'
  local promo_type_lkp = require 'promo_type_lkp'

  T.pstatus = Q.lkp_SC(T.promotion_status, promo_status_lkp):set_name("pstatus")
  T.pchannel = Q.lkp_SC(T.promotion_channel, promo_channel_lkp):set_name("pchannel")
  T.pvehicle = Q.lkp_SC(T.promotion_vehicle, promo_vehicle_lkp):set_name("pvehicle")
  T.ptype = Q.lkp_SC(T.promotion_type, promo_type_lkp):set_name("ptype")
  --====================================
  local chunk_num = 0
  while true do 
    local n, c = T.promo_start:get_chunk(chunk_num)
    if ( n == 0 ) then asert(not c) break end 
    T.promo_end:get_chunk(chunk_num)
    T.promo_mod:get_chunk(chunk_num)
    --========================
    T.pstatus:get_chunk(chunk_num)
    T.pchannel:get_chunk(chunk_num)
    T.pvehicle:get_chunk(chunk_num)
    T.ptype:get_chunk(chunk_num)
    --========================
    T.visibility_rank:get_chunk(chunk_num)
    T.finance_type:get_chunk(chunk_num)
    T.partition_key:get_chunk(chunk_num)
  end
  return T
end
-- return load_promo
load_promo()
