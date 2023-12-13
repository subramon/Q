local cutils = require 'libcutils'
return function(invec)
  local subs = {}

  assert(type(invec) == "lVector")
  assert(invec:qtype() == "SC")
  assert(invec:has_nulls() == false)

  subs.in_qtype = invec:qtype()
  subs.in_ctype = cutils.str_qtype_to_str_ctype(subs.in_qtype)
  subs.cast_in_as = subs.in_ctype .. " *"
  subs.in_width = invec:width()

  subs.out_qtype = "CUSTOM1"
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.cast_out_as = subs.out_ctype .. " *"
  subs.out_width = cutils.get_width_qtype(subs.out_qtype)
  subs.max_num_in_chunk  = invec:max_num_in_chunk()
  subs.bufsz = subs.max_num_in_chunk * subs.out_width

  subs.srcs = { "UTILS/custom_code/src/custom1.c" }
  subs.incs = { "UTILS/custom_code/inc/", "UTILS/inc/" }
  return subs
end
