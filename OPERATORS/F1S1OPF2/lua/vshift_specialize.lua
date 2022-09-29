local ffi     = require 'ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local Scalar  = require 'libsclr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local max_num_in_chunk = qcfg.max_num_in_chunk
local q_src_root       = qcfg.q_src_root

return function (
  f1,
  shift_by,
  newval,
  optargs
  )
  local tmpl = q_src_root .. "/OPERATORS/F1S1OPF2/lua/is_prev.tmpl"
  local subs = {}
  --===========================================
  assert(type(f1) == "lVector")
  local max_num_in_chunk = f1:max_num_in_chunk()
  local in_qtype = f1:qtype()
  assert(f1:has_nulls() == false)   -- limitation of current implementation
  --=================================
  -- positive "by" means shift up, negative means shift down
  assert(type(by) == "number") 
  local abs_by = by; if ( abs_by < 0 ) then abs_by = abs_by * -1 end
  assert(abs_by < max_num_in_chunk) -- limitation of current implementation
  --=================================
  -- when you shift, you introduce holes that are filled with newval
  if ( not newval ) then 
    newval = Scalar.new(0, f1:qtype())
  end
  assert(type(newval) == "Scalar")
  assert(newval:qtype() == f1:qtype()) -- TODO P4 relax limitation
  --===========================================
  subs.in_qtype = in_qtype
  subs.in_ctype = cutils.str_qtype_to_str_ctype(in_qtype)

  subs.out_qtype = out_qtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(out_qtype)

  subs.f1_cast_as = subs.in_ctype  .. "*" 
  subs.f2_cast_as = subs.out_ctype .. "*" 

  bufsz = max_num_in_chunk * cutils.get_width_qtype(out_qtype)

  subs.tmpl        = "OPERATORS/F1S1OPF2/lua/is_prev_" .. out_qtype.. ".tmpl"
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  --==============================
  return subs, tmpl
end
