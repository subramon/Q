local ffi     = require 'ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local Scalar  = require 'libsclr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local is_in   = require 'RSUTILS/lua/is_in'
local cutils  = require 'libcutils'
local q_src_root       = qcfg.q_src_root

local cmps = { "gt", "lt", "geq", "leq", "eq", "neq" }
return function (
  invec, 
  cmp,
  optargs
  )
  local subs = {}
  assert(type(invec) == "lVector")
  assert(type(cmp) == "string")
  assert(is_in(cmp, cmps))

  --================================================
  subs.default_val = false 
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( type(optargs.default_val) ~= "nil" ) then 
      subs.default_val = optargs.default_val
    end
  end
  assert(type(subs.default_val) == "boolean")
  --================================================
  subs.out_qtype = "BL"
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( type(optargs.out_qtype) ~= "nil" ) then 
      subs.out_qtype = optargs.out_qtype
    end
  end
  assert(type(subs.out_qtype) == "string")
  --================================================
  --== check the comparison 
  subs.in_qtype = invec:qtype()
  assert(is_base_qtype(subs.in_qtype))
  if ( cmp == "gt" ) then
    subs.cmp_op = " >  " 
  elseif ( cmp == "lt" ) then
    subs.cmp_op = " <  " 
  elseif ( cmp == "geq" ) then
    subs.cmp_op = " >= " 
  elseif ( cmp == "leq" ) then
    subs.cmp_op = " <= " 
  elseif ( cmp == "eq" ) then
    subs.cmp_op = " == " 
  elseif ( cmp == "neq" ) then
    subs.cmp_op = " != " 
  else
    assert(nil, "invalid comparison" .. cmp)
  end
  --===========================================
  subs.in_ctype = cutils.str_qtype_to_str_ctype(subs.in_qtype)
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)

  subs.f1_cast_as = subs.in_ctype  .. "*" 
  subs.f2_cast_as = subs.out_ctype .. "*" 

  subs.max_num_in_chunk = invec:max_num_in_chunk()
  if ( subs.out_qtype == "B1" ) then 
    subs.bufsz = subs.max_num_in_chunk / 8
  else
    subs.bufsz = subs.max_num_in_chunk * 1
  end
  subs.fn = "is_prev_" .. cmp .. "_" .. subs.in_qtype .. 
    "_" .. subs.out_qtype

  subs.tmpl        = "OPERATORS/F1S1OPF2/lua/is_prev_" .. 
    subs.out_qtype .. ".tmpl"
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  --==============================
  return subs
end
