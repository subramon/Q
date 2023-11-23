local ffi     = require 'ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local Scalar  = require 'libsclr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local cutils  = require 'libcutils'
local max_num_in_chunk = qcfg.max_num_in_chunk
local q_src_root       = qcfg.q_src_root

return function (
  f1
  s1, 
  optargs
  )
  local subs = {}
  --=====================
  assert(type(f1) == "lVector")
  assert(f1:has_nulls() == false)
  assert(f1:qtype() == "SC")
  local max_num_in_chunk = f1:max_num_in_chunk()
  if ( type(s1) == "string" ) then 
    s1 = Scalar.new(s1, "SC")
  end
  assert(type(s1) == "Scalar")
  subs.sclr = s1
  --=====================
  subs.fn = "vstrcmp"
  subs.out_qtype = "BL"
  subs.out_width = 1 -- TODO P4 improve 
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  subs.bufsz  = subs.out_width * subs.max_num_in_chunk 
  subs.cast_f1_as = "char *"
  subs.cast_f2_as = "bool *"

  subs.tmpl        = "OPERATORS/F1S1OPF2/lua/is_prev_" .. out_qtype.. ".tmpl"
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  --==============================
  return subs, tmpl
end
