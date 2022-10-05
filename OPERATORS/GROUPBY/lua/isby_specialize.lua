local cutils = require 'libcutils'

return function (
  src_val,
  src_lnk,
  dst_lnk,
  optargs
  )
  local subs = {}
  assert(type(src_val) == "lVector")
  assert(type(src_lnk) == "lVector")
  assert(type(dst_lnk) == "lVector")

  assert(src_val:has_nulls() == false)
  assert(src_lnk:has_nulls() == false)
  assert(dst_lnk:has_nulls() == false)
  
  subs.src_val_qtype = src_val:qtype()
  subs.src_lnk_qtype = src_lnk:qtype()
  subs.dst_lnk_qtype = dst_lnk:qtype()
  assert(subs.src_lnk_qtype == subs.dst_lnk_qtype)
  subs.dst_val_qtype = subs.src_val_qtype

  subs.fn = "isby_" .. subs.src_lnk_qtype .. "_" .. subs.src_val_qtype 

  subs.src_lnk_ctype = cutils.str_qtype_to_str_ctype(subs.src_lnk_qtype)
  subs.src_val_ctype = cutils.str_qtype_to_str_ctype(subs.src_val_qtype)
  subs.dst_lnk_ctype = cutils.str_qtype_to_str_ctype(subs.dst_lnk_qtype)
  subs.dst_val_ctype = cutils.str_qtype_to_str_ctype(subs.dst_val_qtype)

  subs.max_num_in_chunk = dst_lnk:max_num_in_chunk()
  subs.width    = src_val:width()
  subs.bufsz    = subs.max_num_in_chunk * subs.width 
  subs.nn_bufsz = subs.max_num_in_chunk * 1

  subs.tmpl   = "OPERATORS/GROUPBY/lua/isby.tmpl"
  subs.srcdir = "OPERATORS/GROUPBY/gen_src/"
  subs.incdir = "OPERATORS/GROUPBY/gen_inc/"
  subs.incs =  { "OPERATORS/GROUPBY/gen_inc/", "UTILS/inc/", }
  return subs
end
