local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local plfile = require 'pl.file'
local Scalar  = require 'libsclr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
return function (
  qtype,
  comparison,
  optargs
  )
  local default_val 
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/is_prev.tmpl"
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.default_val ) then 
      assert(type(optargs.default_val) == "number")
      default_val = optargs.default_val
      assert( ( default_val == 1 ) or ( default_val == 0 ) ) 
    end
  end
  if ( not default_val ) then default_val = 1 end
  assert(default_val)
  local subs = {}
  --== check the comparison 
  assert(is_base_qtype(qtype))
  if ( comparison == "gt" ) then
    subs.cmp_op = " <= " 
  elseif ( comparison == "lt" ) then
    subs.cmp_op = " >= " 
  elseif ( comparison == "geq" ) then
    subs.cmp_op = " < " 
  elseif ( comparison == "leq" ) then
    subs.cmp_op = " > " 
  elseif ( comparison == "eq" ) then
    subs.cmp_op = " == " 
  elseif ( comparison == "neq" ) then
    subs.cmp_op = " != " 
  else
    assert(nil, "invalid comparison" .. comparison)
  end
  --===========================================
  subs.qtype = qtype
  subs.ctype = qconsts.qtypes[qtype].ctype
  subs.fn = "is_prev_" .. comparison .. "_" .. qtype
  subs.tmpl = tmpl
  subs.default_val = default_val
  --==============================
  return subs, tmpl
end
