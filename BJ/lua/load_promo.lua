local cutils  = require 'libcutils'
local cVector = require 'libvctr'
local plutils = require 'pl.utils'
local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
require 'Q/UTILS/lua/strict'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
--=======================================================
local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
local function load_promo(is_debug)
  assert(type(is_debug) == "boolean")
  local M = {}
  local O = { is_hdr = false }
  M[#M+1] = { name = "promotion_id", qtype = "I4", has_nulls = false, memo_len = -1 }
  M[#M+1] = { name = "promotion_start_ct_ts", qtype = "SC", width = 24, has_nulls = false, memo_len = 1  }
  M[#M+1] = { name = "promotion_end_ct_ts", qtype = "SC", width = 24, has_nulls = false, memo_len = 1  }
  M[#M+1] = { name = "promotion_status", qtype = "SC", width = 16, has_nulls = false, memo_len = 1  }
  M[#M+1] = { name = "promotion_channel", qtype = "SC", width = 24, has_nulls = true, memo_len = 1  }
  M[#M+1] = { name = "promotion_vehicle", qtype = "SC", width = 24, has_nulls = true, memo_len = 1  }
  M[#M+1] = { name = "promotion_type", qtype = "SC", width = 24, has_nulls = false, memo_len = 1  }
  M[#M+1] = { name = "modified_ct_ts", qtype = "SC", width = 24, has_nulls = false, memo_len = 1  }
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
  local format = "%Y-%m-%d"
  T.promo_start_tm = Q.SC_to_TM(T.promotion_start_ct_ts, 
    format, { out_qtype = "TM1" }):set_name("promo_start_tm"):memo(1)
  T.promo_end_tm = Q.SC_to_TM(T.promotion_end_ct_ts, 
    format, { out_qtype = "TM1" }):set_name("promo_end_tm"):memo(1)
  T.promo_mod_tm = Q.SC_to_TM(T.modified_ct_ts, 
    format, { out_qtype = "TM1" }):set_name("promo_mod_tm"):memo(1)
  --====================================
  T.promo_start = Q.tm_to_epoch(T.promo_start_tm):set_name("promo_start")
  T.promo_end = Q.tm_to_epoch(T.promo_end_tm):set_name("promo_end")
  T.promo_mod = Q.tm_to_epoch(T.promo_mod_tm):set_name("promo_mod")
  --====================================
  local promo_status_lkp  = require 'promo_status_lkp'
  local promo_channel_lkp = require 'promo_channel_lkp'
  local promo_vehicle_lkp = require 'promo_vehicle_lkp'
  local promo_type_lkp    = require 'promo_type_lkp'

  T.pstatus  = Q.SC_to_lkp(T.promotion_status, promo_status_lkp):set_name("pstatus")
  T.pchannel = Q.SC_to_lkp(T.promotion_channel, promo_channel_lkp):set_name("pchannel")
  T.pvehicle = Q.SC_to_lkp(T.promotion_vehicle, promo_vehicle_lkp):set_name("pvehicle")
  T.ptype    = Q.SC_to_lkp(T.promotion_type, promo_type_lkp):set_name("ptype")
  --====================================
  local chunk_num = 0
  local num_elements = 0 
  while true do 
    print("Getting chunk " .. chunk_num)
    local n, c = T.promo_start:get_chunk(chunk_num)
    if ( n ~= 0 ) then 
      T.promo_start:unget_chunk(chunk_num)
    end
    num_elements = num_elements + n
    --========================
    T.promo_end:get_chunk(chunk_num)
    T.promo_mod:get_chunk(chunk_num)
    --========================
    T.pstatus:get_chunk(chunk_num)
    T.pchannel:get_chunk(chunk_num)
    T.pvehicle:get_chunk(chunk_num)
    T.ptype:get_chunk(chunk_num)
    --========================
    --[[
    T.visibility_rank:get_chunk(chunk_num)
    T.finance_type:get_chunk(chunk_num)
    T.partition_key:get_chunk(chunk_num)
    --]]

    T.promo_end:unget_chunk(chunk_num)
    T.promo_mod:unget_chunk(chunk_num)
    --========================
    T.pstatus:unget_chunk(chunk_num)
    T.pchannel:unget_chunk(chunk_num)
    T.pvehicle:unget_chunk(chunk_num)
    T.ptype:unget_chunk(chunk_num)
    --========================
    if ( n < T.ptype:max_num_in_chunk() ) then 
      for k, v in pairs(T) do v:eov() end 
      print("ALL DONE, num_elements = ", num_elements)
      break 
    end 
    chunk_num = chunk_num + 1 
  end
  if ( is_debug ) then 
    cVector.check_all()
  end 
  -- we do not need nulls for these 
  -- In general, it is a bad idea to drop nulls when they are needed
  -- However, because of the particular query we are doing, it is okay
  T.pstatus:drop_nulls()
  T.pchannel:drop_nulls()
  T.pvehicle:drop_nulls()
  T.ptype:drop_nulls()
  T.visibility_rank:drop_nulls()
  T.finance_type:drop_nulls()
 
  return T
end
return load_promo
--[[ 
-- UNIT TEST 
local T = load_promo()
for k, v in pairs(T) do v:delete() end 
cVector.check_all(true)
print("All done")
--]]
