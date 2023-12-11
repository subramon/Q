local cutils = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'

local function SC_to_lkp_specialize(invec, lkp_tbl, optargs)
  local subs = {}
  assert(type(invec) == "lVector")
  assert(invec:qtype() == "SC")
  subs.has_nulls = false
  if ( invec:has_nulls() ) then 
    assert(invec:nn_qtype() == "BL") -- TODO P3 Support B1
    subs.has_nulls = true
  end
  assert(type(lkp_tbl) == "table")
  if ( optargs ) then 
    assert(type(optargs) == "table")
  end
  assert(#lkp_tbl > 0)
  -- TODO P3 Consider using UI1 and UI2 instead 
  if ( #lkp_tbl < 127 ) then
    subs.out_qtype = "I1"
  elseif ( #lkp_tbl < 32767 ) then
    subs.out_qtype = "I2"
  else
    error("TODO")
  end
  for k, v in ipairs(lkp_tbl) do 
    assert(type(v) == "string")
  end
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.cast_buf_as = subs.out_ctype .. " *"
  subs.max_num_in_chunk = invec:max_num_in_chunk()
  subs.out_width = cutils.get_width_qtype(subs.out_qtype)
  subs.bufsz = subs.max_num_in_chunk * subs.out_width 

  subs.nn_bufsz = subs.max_num_in_chunk 
  subs.nn_out_qtype = "BL" -- TODO P3 Consider supporting B1
  subs.nn_out_ctype = cutils.str_qtype_to_str_ctype(subs.nn_out_qtype)
  subs.nn_cast_buf_as = "bool *"

  subs.in_width = invec:width()

  return subs
end
return SC_to_lkp_specialize
