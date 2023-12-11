local Q = require 'Q'
local cutils = require 'libcutils'
local qcfg = require 'Q/UTILS/lua/qcfg'
local mk_rev_lkp = require 'mk_rev_lkp'

-- START CONFIGURATIONS
local modified_ct_cutoff = "2022-09-07"
local promo_date_diff = 45 * 86400 -- 45 days
local promo_status_lkp  = require 'promo_status_lkp'
local promo_channel_lkp = require 'promo_channel_lkp'
local promo_vehicle_lkp = require 'promo_vehicle_lkp'
local promo_type_lkp    = require 'promo_type_lkp'
-- STOP  CONFIGURATIONS

local rev_pstatus_lkp  = mk_rev_lkp(promo_status_lkp)
local rev_pchannel_lkp = mk_rev_lkp(promo_channel_lkp)
local rev_pvehicle_lkp = mk_rev_lkp(promo_vehicle_lkp)
local rev_ptype_lkp    = mk_rev_lkp(promo_type_lkp)

local function time_selector(T, calendar_lb, calendar_ub)
  local a1 = Q.vsgeq(T.promo_start, calendar_lb)
  local a2 = Q.vslt(T.promo_end, calendar_ub)
  local a = Q.vvand(a1, a2)
  return a
end

local function channel_selector(T)
  local b1 = Q.vseq(T.pchannel, rev_pchannel_lkp['online_and_store'])
  local b2 = Q.vseq(T.pchannel, rev_pchannel_lkp['store_only'])
  local b  = Q.vvor(b1, b2)
  return b
end 

local function type_selector(T)
  return b
end 

local function vehicle_cart(T)
  local b = Q.vseq(T.pvehicle, rev_pvehicle_lkp['CARTWHEEL'])
  return b
end

local function vehicle_tpc_circ(T)
  return   Q.vvor(
    Q.vseq(T.pvehicle, rev_pvehicle_lkp['TPC']),
    Q.vseq(T.pvehicle, rev_pvehicle_lkp['CIRCULAR'])
    )
end

local function vehicle_tpc_circ_cart(T)
  local b1 = Q.vseq(T.pvehicle, rev_pvehicle_lkp['TPC'])
  local b2 = Q.vseq(T.pvehicle, rev_pvehicle_lkp['CIRCULAR'])
  local b3 = Q.vseq(T.pvehicle, rev_pvehicle_lkp['CARTWHEEL'])
  local b4  = Q.vvand(b1, b2)
  local b   = Q.vvor(b4, b3)
  return b
end 

local function status_selector(T)
  local b1 = Q.vseq(T.pstatus, rev_pstatus_lkp['ready'])
  local b2 = Q.vseq(T.pstatus, rev_pstatus_lkp['messaging'])
  local b3 = Q.vseq(T.pstatus, rev_pstatus_lkp['live'])
  local b4 = Q.vseq(T.pstatus, rev_pstatus_lkp['completed'])
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

--  DATEDIFF(promotion_end_ct_ts,promotion_start_ct_ts) <= 45)
local function date_diff(T)
  return Q.vsleq(Q.vvsub(T.promo_end, T.promo_start), promo_date_diff)
end


local function select_promo(
  T,
  calendar_lb,
  calendar_ub
  )
  
    -- IMPORTANT: CHANGE TO GLOBAL BELOW 
  -- package.loaded['Q/UTILS/lua/qcfg'].memo_len = 1
  qcfg._modify("memo_len", 1)
  qcfg._modify("is_killable", true)
    -- b.calendar_d between a.promotion_start_ct_ts and a.promotion_end_ct_ts
  local a  = time_selector(T, calendar_lb, calendar_ub)
  -- lower(promotion_status) in ('ready','messaging','live', 'completed']
  local b = status_selector(T)
  -- AND lower(promotion_channel) in ('online_and_store', 'store_only']
  local c = channel_selector(T)
  -- AND UPPER(trim(promotion_vehicle)) IN ('TPC', 'CIRCULAR', 'CARTWHEEL']
  local d = vehicle_tpc_circ_cart(T)
  -- (promotion_type = 'Sale']
  local is_sale = Q.vseq(T.ptype, rev_ptype_lkp['Sale'])
  -- (promotion_type = 'basket']
  local is_basket = Q.vseq(T.ptype, rev_ptype_lkp['Basket'])
  --  visibility_rank <> -1 AND
  local is_visible = Q.vsneq(T.visibility_rank, -1)
  --  finance_type in (11, 22, 23, 26, 28)
  local is_finance = finance_selector(T)
  --  modified_ct_ts > '2022-09-07'
  local is_gt_promo_mod = Q.vsgt(T.promo_mod, 
    cutils.date_str_to_epoch(modified_ct_cutoff, "%Y-%m-%d"))
  --  modified_ct_ts <= '2022-09-07'
  local is_leq_promo_mod = Q.vnot(is_gt_promo_mod)
  -- UPPER(trim(promotion_vehicle)) IN ('TPC', 'CIRCULAR']
  local is_v_tpc_circ = vehicle_tpc_circ(T)
  -- UPPER(trim(promotion_vehicle)) IN ('CARTWHEEL']
  local is_v_cart = vehicle_cart(T)
  -- FAKE TODO TODO 
  local is_date_diff = date_diff(T)
  

  local cond1 = is_sale
  local cond2 = Q.vvand( Q.vvand(Q.vvand(
    is_basket, is_visible), is_finance), is_gt_promo_mod)
  local cond3 = Q.vvand(Q.vvand(Q.vvand(Q.vvand(
    is_basket, is_v_tpc_circ), is_visible), is_finance), is_leq_promo_mod)
  local cond4 = Q.vvand(Q.vvand(Q.vvand(Q.vvand(Q.vvand(
    is_basket, is_v_cart), is_visible), is_finance), is_leq_promo_mod), is_date_diff)
  
  local e = Q.vvor(Q.vvor(Q.vvor(cond1, cond2), cond3), cond4)

  local cond = Q.vvand(Q.vvand(Q.vvand(Q.vvand(a, b), c), d), e)

    -- IMPORTANT: CHANGE TO GLOBAL BELOW 
  -- package.loaded['Q/UTILS/lua/qcfg'].memo_len = -1
  qcfg._modify("memo_len", -1)
  qcfg._modify("is_killable", false)
  cond:memo(-1)
  cond:killable(false)
  assert(cond:memo_len() == -1)
  return cond
end
return select_promo
