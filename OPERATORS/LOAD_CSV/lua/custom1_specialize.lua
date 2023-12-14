local cutils = require 'libcutils'
return function(invec)
  local subs = {}

  assert(type(invec) == "lVector")
  assert(invec:qtype() == "SC")
  assert(invec:has_nulls() == false)

  subs.in_qtype = invec:qtype()
  subs.cast_in_as = "char *"
  subs.in_width = invec:width()

  subs.out_qtype = "CUSTOM1"
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.cast_out_as = subs.out_ctype .. " *"
  subs.out_width = cutils.get_width_qtype(subs.out_qtype)
  subs.max_num_in_chunk  = invec:max_num_in_chunk()
  subs.bufsz = subs.max_num_in_chunk * subs.out_width

  subs.fn = "mk_custom1"
  subs.dotc = "UTILS/src/custom_code/src/mk_custom1.c"
  subs.doth = "UTILS/src/custom_code/inc/mk_custom1.h"
  subs.incs = { "UTILS/inc", "UTILS/src/custom_code/inc/", }

  return subs
end
