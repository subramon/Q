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
  return Q.vvor(
    Q.vvand(Q.vslt(T.promo_start, calendar_lb),
                     Q.vsgeq(T.promo_end, calendar_lb)),
            Q.vslt(T.promo_start, calendar_ub)
            )
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
    Q.vseq(T.pvehicle, rev_pvehicle_lkp['TPC']):set_name("1 tpc"), 
    Q.vseq(T.pvehicle, rev_pvehicle_lkp['CIRCULAR']):set_name("1 circular")
    )
end

local function vehicle_tpc_circ_cart(T)
  local b1 = Q.vseq(T.pvehicle, rev_pvehicle_lkp['TPC'])
  local b2 = Q.vseq(T.pvehicle, rev_pvehicle_lkp['CIRCULAR'])
  local b3 = Q.vseq(T.pvehicle, rev_pvehicle_lkp['CARTWHEEL'])
  local b4  = Q.vvor(b1, b2)
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
  local b1 = Q.vseq(T.finance_type, 11):set_name("f 1")
  local b2 = Q.vseq(T.finance_type, 22):set_name("f 22")
  local b3 = Q.vseq(T.finance_type, 23):set_name("f 23")
  local b4 = Q.vseq(T.finance_type, 26):set_name("f 26")
  local b5 = Q.vseq(T.finance_type, 28):set_name("f 28")
  local b6 = Q.vvor(b1, b2):set_name("f 6")
  local b7 = Q.vvor(b6, b3):set_name("f 7")
  local b8 = Q.vvor(b7, b4):set_name("f 8")
  local b  = Q.vvor(b8, b5)
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
  local a  = time_selector(T, calendar_lb, calendar_ub):set_name("a")
  -- lower(promotion_status) in ('ready','messaging','live', 'completed']
  local b = status_selector(T):set_name("b")
  -- AND lower(promotion_channel) in ('online_and_store', 'store_only']
  local c = channel_selector(T):set_name("c")
  -- AND UPPER(trim(promotion_vehicle)) IN ('TPC', 'CIRCULAR', 'CARTWHEEL']
  local d = vehicle_tpc_circ_cart(T):set_name("d")
  -- (promotion_type = 'basket']
  local is_basket = Q.vseq(T.ptype, rev_ptype_lkp['Basket'])
  is_basket:memo(-1):killable(false):set_name("is_basket")
  --  visibility_rank <> -1 AND
  local is_visible = Q.vsneq(T.visibility_rank, -1)
  is_visible:memo(-1):killable(false):set_name("is_visible")
  --  finance_type in (11, 22, 23, 26, 28)
  local is_finance = finance_selector(T)
  is_finance:memo(-1):killable(false):set_name("is_finance")
  --  modified_ct_ts > '2022-09-07'
  local is_gt_promo_mod = Q.vsgt(T.promo_mod, 
    cutils.date_str_to_epoch(modified_ct_cutoff, "%Y-%m-%d")):set_name("is_gt_promo_mod")
  is_gt_promo_mod:memo(-1):killable(false):set_name("is_gt_promo_mod")
  --  modified_ct_ts <= '2022-09-07'
  local is_leq_promo_mod = Q.vnot(is_gt_promo_mod)
  is_leq_promo_mod:memo(-1):killable(false):set_name("is_leq_promo_mod")
  -- UPPER(trim(promotion_vehicle)) IN ('TPC', 'CIRCULAR']
  local is_v_tpc_circ = vehicle_tpc_circ(T):set_name("is_v_tpc_circ")
  -- UPPER(trim(promotion_vehicle)) IN ('CARTWHEEL']
  local is_v_cart = vehicle_cart(T):set_name("is_v_cart")
  local is_date_diff = date_diff(T):set_name("is_date_diff")
  
  -- (promotion_type = 'Sale']
  local cond1 = Q.vseq(T.ptype, rev_ptype_lkp['Sale'])
  cond1:memo(-1):killable(false)
  cond1:memo(1):killable(true)

  local cond2 = Q.vvand(Q.vvand(Q.vvand(
    is_basket, is_visible):set_name("c21"), is_finance):set_name("c22"), is_gt_promo_mod):set_name("cond2")
  cond2:memo(-1):killable(false)
  cond2:memo(1):killable(true)

  local cond3 = Q.vvand(Q.vvand(Q.vvand(Q.vvand(
    is_basket, is_v_tpc_circ):set_name("c31"), is_visible):set_name("c32"), is_finance):set_name("c33"), is_leq_promo_mod):set_name("cond3")
  cond3:memo(1):killable(true)
  cond3:memo(-1):killable(false)

  local cond4 = Q.vvand(Q.vvand(Q.vvand(
    Q.vvand(
      Q.vvand(is_basket, is_v_cart):set_name("c41"), is_visible):set_name("c42"), is_finance):set_name("c43"), is_leq_promo_mod):set_name("c44"), is_date_diff):set_name("cond4")
  cond4:memo(-1):killable(false)
  cond4:memo(1):killable(true)

  local e = Q.vvor(Q.vvor(Q.vvor(cond1, cond2):set_name("cond12"), cond3):set_name("cond123"), cond4):set_name("cond1234")
  e:memo(-1):killable(false)
  e:memo(1):killable(true)

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
