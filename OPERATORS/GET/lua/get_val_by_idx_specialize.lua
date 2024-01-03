local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_int_qtype = require 'Q/UTILS/lua/is_int_qtype'
local cutils    = require 'libcutils'

return function (x, y, optargs)
  local subs = {}
  assert(type(x) == "lVector")
  subs.xqtype = x:qtype()
  assert(subs.xqtype ~= "SC")
  assert(subs.xqtype ~= "TM")
  assert(type(y) == "lVector")
  subs.yqtype = y:qtype()
  assert(is_int_qtype(subs.yqtype))

  if ( x:has_nulls() ) then
    assert(x:nn_qtype() == "BL")
  end
  subs.nn_xqtype = x:nn_qtype()
  subs.nn_xctype = cutils.str_qtype_to_str_ctype(subs.nn_xqtype)
  subs.cast_nn_x_as = subs.nn_xctype .. " *"

  subs.xctype = cutils.str_qtype_to_str_ctype(subs.xqtype)
  subs.cast_x_as = subs.xctype .. " *"

  subs.yctype = cutils.str_qtype_to_str_ctype(subs.yqtype)
  subs.cast_x_as = subs.yctype .. " *"

  subs.out_qtype = subs.xqtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.cast_x_as = subs.out_ctype .. " *"
  subs.width = cutils.get_width_qtype(subs.out_qtype)
  subs.max_num_in_chunk = x:max_num_in_chunk()
  subs.bufsz = subs.width * subs.max_num_in_chunk 

  subs.nn_bufsz = subs.max_num_in_chunk
  subs.nn_out_qtype = "BL"
  subs.cast_nn_out_as = "bool *"

  subs.fn = "get_val_" .. subs.xqtype .. "_by_idx_" .. subs.yqtype 

  return subs
end
