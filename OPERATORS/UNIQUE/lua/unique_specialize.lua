local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
return function (
  x
  )
  local subs = {}; 
  assert(type(x) == "lVector")
  local qtype = x:qtype()
  assert(is_base_qtype(qtype), "type of in must be base type")
  assert(x:has_nulls() == false)

  subs.fn = "unique" .. "_" .. qtype
  subs.max_num_in_chunk = x:max_num_in_chunk()

  subs.val_qtype = qtype
  subs.val_ctype = cutils.str_qtype_to_str_ctype(subs.val_qtype)
  subs.val_width = cutils.get_width_qtype(subs.val_qtype)
  subs.val_bufsz = subs.val_width * subs.max_num_in_chunk

  subs.cnt_qtype = "I8"
  subs.cnt_ctype = cutils.str_qtype_to_str_ctype(subs.cnt_qtype)
  subs.cnt_width = cutils.get_width_qtype(subs.cnt_qtype)
  subs.cnt_bufsz = subs.cnt_width * subs.max_num_in_chunk

  subs.tmpl = "/OPERATORS/UNIQUE/lua/unique.tmpl"
  subs.incdir = "/OPERATORS/UNIQUE/gen)_inc/"
  subs.srcdir = "/OPERATORS/UNIQUE/gen)_src/"

  return subs
end
