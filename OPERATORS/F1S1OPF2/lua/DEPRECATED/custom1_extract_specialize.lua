local ffi     = require 'ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local Scalar  = require 'libsclr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local is_in   = require 'Q/UTILS/lua/is_in'
local cutils  = require 'libcutils'
local q_src_root       = qcfg.q_src_root
local terms = require 'Q/CUSTOM_CODE/CUSTOM1/lua/custom1_spec'

return function (
  f1,
  fld, 
  optargs
  )
  local subs = {}
  --=====================
  assert(type(f1) == "lVector")
  assert(f1:qtype() == "CUSTOM1")
  assert(not f1:has_nulls())
  local max_num_in_chunk = f1:max_num_in_chunk()
  assert(type(fld) == "string")
  assert(is_in(fld, terms))
  local idx = 0
  for k, v in ipairs(terms) do 
    if ( v == fld ) then
      idx = k; break
    end
  end
  assert(idx > 0)
  subs.shift_by = idx - 1;
  --=====================
  subs.in_ctype   = "custom1_t"
  subs.cast_f1_as = "custom1_t *"

  subs.fn = "custom1_extract_" .. fld 
  subs.out_qtype = "F4"
  subs.out_width  = cutils.get_width_qtype(subs.out_qtype)
  subs.out_ctype  = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.cast_f2_as = subs.out_ctype .. " *"

  subs.chunk_size = 128 --- for OpenMP
  subs.max_num_in_chunk = max_num_in_chunk
  subs.bufsz  = subs.out_width * subs.max_num_in_chunk 

  subs.nn_bufsz  = subs.max_num_in_chunk 
  subs.cast_nn_f2_as = "bool *"

  subs.has_nulls = true 

  subs.fld = fld --- this is the field we will extract from custom1_t
  subs.fn = "custom1_extract_" .. subs.fld
  subs.tmpl        = "OPERATORS/F1S1OPF2/lua/custom1_extract.tmpl"
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  --==============================
  return subs
end
