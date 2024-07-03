local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local is_in   = require 'Q/UTILS/lua/is_in'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function unpack_specialize(invec, out_qtypes)
  local subs = {}
  assert(type(invec) == "lVector")
  assert(type(out_qtypes) == "table")
  subs.in_qtype = invec:qtype()
  assert(is_in(subs.in_qtype, { "UI2", "UI4", "UI8", "UI16", }))
  subs.in_ctype = cutils.str_qtype_to_str_ctype(subs.in_qtype)
  subs.in_width = cutils.get_width_qtype(subs.in_qtype)

  subs.max_num_in_chunk = invec:max_num_in_chunk()
  subs.bufszs = {}
  subs.out_widths = {}
  local sum_out_width = 0
  for k, out_qtype in ipairs(out_qtypes) do 
    assert(type(out_qtype) == "string")
    assert(is_in(out_qtype, { 
      "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", 
      "BL", "F4", "F8", }),
      "UNPACK: Not supported out_qtype = " ..  out_qtype)
    subs.out_widths[k] = cutils.get_width_qtype(out_qtype)
    sum_out_width = sum_out_width + subs.out_widths[k] 
    subs.bufszs[k] = subs.max_num_in_chunk * subs.out_widths[k]
  end
  assert(sum_out_width <= subs.in_width)
  --======================================================
  subs.out_qtypes = out_qtypes
  subs.n_vals = #out_qtypes
  subs.c_width = cmem.new({size = ffi.sizeof("uint32_t") * subs.n_vals,
    qtype = "UI4"})
  local width_ptr = get_ptr(subs.c_width, "UI4")
  for k = 1, subs.n_vals  do
    width_ptr[k-1] = subs.out_widths[k]
  end
  --======================================================
  -- cols is meant to hold pointers to chunks of each output vector
  subs.c_cols = cmem.new(ffi.sizeof("char *") * subs.n_vals)

  subs.fn     = "unpack_" .. subs.in_qtype
  subs.tmpl   = "OPERATORS/UNPACK/lua/unpack.tmpl"
  subs.incdir = "OPERATORS/UNPACK/gen_inc/"
  subs.srcdir = "OPERATORS/UNPACK/gen_src/"
  subs.incs   = { "OPERATORS/UNPACK/gen_inc/", "UTILS/inc", }
  return subs
end
return unpack_specialize
