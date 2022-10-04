local cutils = require 'libcutils'

return function (
  src_val,
  src_lnk,
  dst_lnk,
  optargs
  )
  assert(type(src_val) == "lVector")
  assert(type(src_lnk) == "lVector")
  assert(type(dst_val) == "lVector")

  assert(src_val:has_nulls() == "false")
  assert(src_lnk:has_nulls() == "false")
  assert(dst_val:has_nulls() == "false")
  
  local src_val_type = src_val:qtype()
  local src_lnk_type = src_lnk:qtype()
  local dst_lnk_type = dst_lnk:qtype()
  assert(src_lnk_type == dst_lnk_type)
  subs.dst_val_qtype = src_val_qtype

  local subs = {};
  subs.fn = "isby_" .. src_lnk_qtype .. "_" .. src_val_qtype 

  subs.src_lnk_ctype = cutils.str_qtype_to_str_ctype(src_lnk_qtype)
  subs.src_val_ctype = cutils.str_qtype_to_str_ctype(src_val_qtype)
  subs.dst_lnk_ctype = cutils.str_qtype_to_str_ctype(dst_lnk_qtype)
  subs.dst_val_ctype = cutils.str_qtype_to_str_ctype(dst_val_qtype)

  subs.max_num_in_chunk = dst_lnk:max_num_in_chunk()
  subs.width    = src_val:width()
  subs.bufsz    = subs.max_num_in_chunk * subs.width 
  subs.nn_bufsz = subs.max_num_in_chunk * 1

  subs.tmpl   = "OPERATORS/GROUPBY/lua/isby.tmpl"
  subs.srcdir = "OPERATORS/GROUPBY/gen_src/"
  subs.incdir = "OPERATORS/GROUPBY/gen_inc/"
  return subs
end
