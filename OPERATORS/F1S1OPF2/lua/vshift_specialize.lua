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
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  local in_qtype = f1:qtype()
  assert(f1:has_nulls() == false)   -- limitation of current implementation
  --=================================
  -- positive "shift_by" means shift up, negative means shift down
  assert(type(shift_by) == "number") 
  local abs_by = shift_by; if ( abs_by < 0 ) then abs_by = abs_by * -1 end
  -- limitation of current implementation below
  assert(abs_by < subs.max_num_in_chunk) 
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

  subs.out_qtype = in_qtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)

  subs.f1_cast_as = subs.in_ctype  .. "*" 
  subs.f2_cast_as = subs.out_ctype .. "*" 

  subs.width = cutils.get_width_qtype(subs.out_qtype)
  subs.bufsz = subs.max_num_in_chunk * subs.width
  return subs, tmpl
end
