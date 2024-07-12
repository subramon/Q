local qcfg    = require 'Q/UTILS/lua/qcfg'
local is_in   = require 'RSUTILS/lua/is_in'
local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local tmpl    = qcfg.q_src_root .. "/OPERATORS/F1OPF2F3/lua/split.tmpl"

return function (
  x,
  optargs
  )
  assert(type(x) == "lVector")
  local subs = {}; 

  local in_qtype = x:qtype()
  assert(x:has_nulls() == false) -- TODO P3 to be implemented
  subs.has_nulls = x:has_nulls()
  assert(type(optargs) == "table")
  subs.out_qtypes = assert(optargs.out_qtypes)
  assert(type(subs.out_qtypes) == "table")
  assert(#subs.out_qtypes == 2)

  local valid_out_qtypes
  if ( in_qtype == "I8" ) then 
    valid_out_qtypes = { "I1", "I2", "I4", }
  elseif ( in_qtype == "I4" ) then 
    valid_out_qtypes = { "I1", "I2", }
  elseif ( in_qtype == "I2" ) then 
    valid_out_qtypes = { "I1", }
  else
    error("")
  end
  --========================
  if ( subs.out_qtypes[2] == "I1" ) then 
    subs.shift_by = 1*8
  elseif ( subs.out_qtypes[2] == "I2" ) then 
    subs.shift_by = 2*8
  elseif ( subs.out_qtypes[2] == "I4" ) then 
    subs.shift_by = 4*8
  else
    error("")
  end
  assert(type(subs.shift_by) == "number")
  --========================
  for k, v in ipairs(subs.out_qtypes) do 
    assert(is_in(subs.out_qtypes[k], valid_out_qtypes))
  end
  --========================

  subs.max_num_in_chunk = x:max_num_in_chunk()
  subs.fn = "split_" .. in_qtype .. "_" .. 
    subs.out_qtypes[1]  .. "_" .. subs.out_qtypes[2]

  subs.in_ctype   = cutils.str_qtype_to_str_ctype(in_qtype)

  local out_ctypes = {}
  local out_widths = {}
  local out_cast_as = {}
  local out_bufsz = {}
  for k, out_qtype in ipairs(subs.out_qtypes) do 
    out_ctypes[k] = "u" .. cutils.str_qtype_to_str_ctype(out_qtype)
    out_widths[k] = cutils.get_width_qtype(out_qtype)
    out_cast_as[k] = cutils.str_qtype_to_str_ctype(out_qtype) .. " *"
    out_bufsz[k] = subs.max_num_in_chunk * out_widths[k] 
  end
  subs.out_ctypes  = out_ctypes
  subs.out_widths  = out_widths
  subs.out_cast_as = out_cast_as
  subs.out_bufsz   = out_bufsz

  subs.in_cast_as   = cutils.str_qtype_to_str_ctype(in_qtype)   .. " *"

  subs.tmpl = tmpl
  subs.incdir = "OPERATORS/F1OPF2F3/gen_inc/"
  subs.srcdir = "OPERATORS/F1OPF2F3/gen_src/"
  subs.incs = { "OPERATORS/F1OPF2F3/gen_inc/", "UTILS/inc/", }
  -- following needed for template
  subs.out1_ctype  = subs.out_ctypes[1]
  subs.out2_ctype  = subs.out_ctypes[2]
  return subs
end
