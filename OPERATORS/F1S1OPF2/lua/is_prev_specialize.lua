local ffi     = require 'ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local Scalar  = require 'libsclr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local cutils  = require 'libcutils'
local q_src_root       = qcfg.q_src_root

return function (
  in_qtype,
  comparison,
  optargs
  )
  local default_val 
  local tmpl = q_src_root .. "/OPERATORS/F1S1OPF2/lua/is_prev.tmpl"
  local default_val = false 
  local out_qtype = "BL"
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( type(optargs.default_val) ~= "nil" ) then 
      default_val = optargs.default_val
    end
    if ( type(optargs.out_qtype) ~= "nil" ) then 
      out_qtype = optargs.out_qtype
    end
  end
  assert(type(default_val) == "boolean")
  assert(type(out_qtype) == "string")
  local subs = {}
  --== check the comparison 
  assert(is_base_qtype(in_qtype))
  if ( comparison == "gt" ) then
    subs.cmp_op = " >  " 
  elseif ( comparison == "lt" ) then
    subs.cmp_op = " <  " 
  elseif ( comparison == "geq" ) then
    subs.cmp_op = " >= " 
  elseif ( comparison == "leq" ) then
    subs.cmp_op = " <= " 
  elseif ( comparison == "eq" ) then
    subs.cmp_op = " == " 
  elseif ( comparison == "neq" ) then
    subs.cmp_op = " != " 
  else
    assert(nil, "invalid comparison" .. comparison)
  end
  --===========================================
  subs.in_qtype = in_qtype
  subs.in_ctype = cutils.str_qtype_to_str_ctype(in_qtype)

  subs.out_qtype = out_qtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(out_qtype)

  subs.fn = "is_prev_" .. comparison .. "_" .. in_qtype .. "_" .. out_qtype
  subs.default_val = default_val

  subs.tmpl        = "OPERATORS/F1S1OPF2/lua/is_prev_" .. out_qtype.. ".tmpl"
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  --==============================
  return subs, tmpl
end
