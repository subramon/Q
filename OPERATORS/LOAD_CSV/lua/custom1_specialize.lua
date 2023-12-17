local cutils = require 'libcutils'
--[[ We auto generate code so no longer needed 
local keys = require 'Q/UTILS/src/custom1_terms'
local tbl_of_str_to_C_array = require 'Q/UTILS/lua/tbl_of_str_to_C_array'

assert(type(keys) == "table")
assert(#keys > 0)
for k, v in ipairs(keys) do 
  assert(type(v) == "string")
  assert(#v > 0) for k2, v2 in ipairs(keys) do  -- slow check for uniqueness
    if ( k ~= k2 ) then assert(v ~= v2) end 
  end
end
--]]

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
  subs.dotc = "CUSTOM_CODE/CUSTOM1/src/mk_custom1.c"
  subs.doth = "CUSTOM_CODE/CUSTOM1/inc/mk_custom1.h"
  subs.incs = { "UTILS/inc", "CUSTOM_CODE/CUSTOM1/inc/", }
  subs.libs = { "-ljansson", }

--[[ We auto generate code so no longer needed 
  subs.ckeys = tbl_of_str_to_C_array(keys)
  subs.keys = keys
  --]]

  return subs
end
