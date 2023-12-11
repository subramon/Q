local Q = require 'Q'
local qcfg = require 'Q/UTILS/lua/qcfg'
local mk_rev_lkp = require 'mk_rev_lkp'

local modified_ct_cutoff = "2022-09-07"
local promo_status_lkp  = require 'promo_status_lkp'
local promo_channel_lkp = require 'promo_channel_lkp'
local promo_vehicle_lkp = require 'promo_vehicle_lkp'
local promo_type_lkp    = require 'promo_type_lkp'

local rev_pstatus_lkp  = mk_rev_lkp(promo_status_lkp)
local rev_pchannel_lkp = mk_rev_lkp(promo_channel_lkp)
local rev_pvehicle_lkp = mk_rev_lkp(promo_vehicle_lkp)
local rev_ptype_lkp    = mk_rev_lkp(promo_type_lkp)

local function time_selector(T)
  local a1 = Q.vsleq(T.promo_start, b_calendar_s)
  local a2 = Q.vsgeq(T.promo_end, b_calendar_s)
  local a = Q.vvand(a1, a2)
  return a
end

local function channel_selector(T)
  local b1 = Q.vseq(T.pchannel, rev_pchannel_lkp('online_and_store'))
  local b2 = Q.vseq(T.pchannel, rev_pchannel_lkp('store_only'))
  local b  = Q.vvor(b1, b2)
  return b
end 

local function type_selector(T)
  return b
end 

local function vehicle_tpc_wheel(T)
  local b = Q.vseq(T.pvehicle, rev_pvehicle('CIRCULAR'))
  return b
end

local function vehicle_tpc_circ(T)
  local b1 = Q.vseq(T.pvehicle, rev_pvehicle('TPC'))
  local b2 = Q.vseq(T.pvehicle, rev_pvehicle('CIRCULAR'))
  local b  = Q.vvor(b1, b2)
  return b
end

local function vehicle_selector(T)
  local b1 = Q.vseq(T.pvehicle, rev_pvehicle('TPC'))
  local b2 = Q.vseq(T.pvehicle, rev_pvehicle('CIRCULAR'))
  local b3 = Q.vseq(T.pvehicle, rev_pvehicle('CARTWHEEL'))
  local b4  = Q.vvand(b1, b2)
  local b   = Q.vvor(b4, b3)
  return b
end 

local function status_selector(T)
  local b1 = Q.vseq(T.pstatus, rev_pstatus_lkp('ready'))
  local b2 = Q.vseq(T.pstatus, rev_pstatus_lkp('messaging'))
  local b3 = Q.vseq(T.pstatus, rev_pstatus_lkp('live'))
  local b4 = Q.vseq(T.pstatus, rev_pstatus_lkp('completed'))
  local b5 = Q.vvor(b1, b2)
  local b6 = Q.vvor(b5, b3)
  local b  = Q.vvor(b6, b4)
  return b
end 

local function finance_selector(T)
  local b1 = Q.vseq(T.finance_type, 11)
  local b2 = Q.vseq(T.finance_type, 22)
  local b3 = Q.vseq(T.finance_type, 23)
  local b4 = Q.vseq(T.finance_type, 26)
  local b5 = Q.vseq(T.finance_type, 28)
  local b6 = Q.vvand(b1, b2)
  local b7 = Q.vvand(b6, b3)
  local b8 = Q.vvand(b7, b4)
  local b  = Q.vvand(b8, b5)
  return b
end 


local function select_promotions(
  T,
  b_calendar_s
  )
  
    -- IMPORTANT: CHANGE TO GLOBAL BELOW 
  -- package.loaded['Q/UTILS/lua/qcfg'].memo_len = 1
  qcfg._modify("memo_len", 1)
    -- b.calendar_d between a.promotion_start_ct_ts and a.promotion_end_ct_ts
  local a  = time_selector(T)
  -- lower(promotion_status) in ('ready','messaging','live', 'completed')
  local b = status_selector(T)
  -- AND lower(promotion_channel) in ('online_and_store', 'store_only')
  local c = channel_selector(T)
  -- AND UPPER(trim(promotion_vehicle)) IN ('TPC', 'CIRCULAR', 'CARTWHEEL')
  local d = vehicle_selector(T)
  -- (promotion_type = 'Sale')
  local is_sale = Q.vseq(T.ptype, rev_ptype_lkp('Sale'))
  -- (promotion_type = 'basket')
  local is_basket = Q.vseq(T.ptype, rev_ptype_lkp('Basket'))
  --  visibilit y_rank <> -1 AND
  local is_visible = Q.vsneq(T.visibility_rank, -1)
  --  finance_type in (11, 22, 23, 26, 28)
  local is_finance = finance_selector(T)
  --  modified_ct_ts > '2022-09-07'
  local is_gt_promo_mod = Q.vsgt(T.promo_mod, 
    cutils.date_str_to_epoch(modified_ct_cutoff, "%Y-%m-%d"))
  --  modified_ct_ts <= '2022-09-07'
  local is_leq_promo_mod = Q.vnot(is_gt_promo_mod)
  -- UPPER(trim(promotion_vehicle)) IN ('TPC', 'CIRCULAR')
  local is_v_tpc_circ = vehicle_tpc_circ(T)
  -- UPPER(trim(promotion_vehicle)) IN ('CARTWHEEL')
  local is_v_wheel = vehicle_wheel(T)
  
  
    -- IMPORTANT: CHANGE TO GLOBAL BELOW 
  -- package.loaded['Q/UTILS/lua/qcfg'].memo_len = -1
  qcfg._modify("memo_len", -1)
  b:memo(-1)
  return b_calendar_s
end
return select_promotions
