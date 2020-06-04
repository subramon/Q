local qconsts  = require 'Q/UTILS/lua/q_consts'
local ffi      = require 'ffi' 
local cVector  = require 'libvctr' 
local cutils   = require 'libcutils' 
local qc       = require 'Q/UTILS/lua/q_core'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local cmem     = require 'libcmem'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local record_time = require 'Q/UTILS/lua/record_time'
local is_in    = require 'Q/UTILS/lua/is_in'
-- TODO Implement chk_subs

local no_scalar_ops = { "vnot", "incr", "decr", "exp", "log", "sqrt" }

local function expander_f1s1opf2(a, f1, y, optargs )
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  assert(f1, "Need to provide vector for"  .. a)
  assert(type(f1) == "lVector", 
  "first argument for " .. a .. "should be vector")
  assert(not f1:has_nulls())
  if ( optargs ) then 
    assert(type(optargs) == "table")
  else
    optargs = {}
  end
  if ( is_in(a, no_scalar_ops) ) then 
    --y not defined if no scalar like in incr, decr, exp, log
    assert(not y)
  else 
    y = assert(to_scalar(y, f1:fldtype()))
  end
  -- following useful for cum_cnt TODO TODO 
  if ( f1:is_eov() ) then optargs.in_nR = f1:length() end
  --========================
  local status, subs, tmpl = pcall(spfn, f1:fldtype(), y, optargs)
  if ( not status ) then error(subs) end 
  -- assert(chk_subs(subs))
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Missing symbol " .. func_name)

  local ptr_sclr 
  if ( y ) then 
    local cstruct   = assert(subs.args)
    ptr_sclr = get_ptr(cstruct, subs.in_qtype)
  end
  local f2_qtype  = assert(subs.out_qtype)
  local f2_width  = qconsts.qtypes[f2_qtype].width
  local buf_sz    = cVector.chunk_size() * f2_width
  local f2_buf    = cmem.new(0)
  local cst_f1_as = subs.in_ctype  .. "*" 
  local cst_f2_as = subs.out_ctype .. "*" 
  local l_chunk_num = 0

  --============================================
  local f2_gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    if ( not f2_buf:is_data() ) then 
      f2_buf = assert(cmem.new( { size = buf_sz, qtype = f2_qtype}))
      f2_buf:stealable(true)
    end
    local f1_len, f1_chunk, nn_f1_chunk = f1:get_chunk(l_chunk_num)
    if ( f1_len == 0 ) then return 0 end 
    local cst_f1_chunk    = get_ptr(f1_chunk, cst_f1_as)
    local cst_f2_buf      = get_ptr(f2_buf,   cst_f2_as)
    local start_time = cutils.rdtsc()
    status = qc[func_name](cst_f1_chunk, f1_len, ptr_sclr, cst_f2_buf)
    assert(status)
    f1:unget_chunk(l_chunk_num)
    record_time(start_time, func_name)
    l_chunk_num = l_chunk_num + 1
    return f1_len, f2_buf
  end
  return lVector{gen=f2_gen, has_nulls=false, qtype=f2_qtype}
end return expander_f1s1opf2
