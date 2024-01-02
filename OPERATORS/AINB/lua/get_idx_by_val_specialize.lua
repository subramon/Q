local cutils = require 'libcutils'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

local function get_idx_by_val_specialize(x, y)
  local subs = {}; 
  assert(type(x) == "lVector")
  assert(type(y) == "lVector")
  assert(x:has_nulls() == false)
  assert(y:has_nulls() == false)
  -- all values of y must exist 
  if ( y:is_eov() == false )  then y:eval() end
  -- we need LMA access to y
  if ( y:is_lma() == false ) then y:chunks_to_lma() end

  subs.in_qtype = x:qtype()
  assert(is_base_qtype(subs.in_qtype))
  assert(x:qtype() == y:qtype()) -- x and y must have same types
  if ( y:get_meta("sort_order") == "asc" ) then
    subs.fn = "get_idx_by_val_binary_search_" .. x:qtype()
    subs.tmpl = "OPERATORS/AINB/lua/get_idx_by_val_binary_search.tmpl"
  else
    subs.fn = "get_idx_by_val_linear_search_" .. x:qtype()
    subs.tmpl = "OPERATORS/AINB/lua/get_idx_by_val_linear_search.tmpl"
  end
  subs.in_ctype = cutils.str_qtype_to_str_ctype(subs.in_qtype)
  subs.cast_x_as = subs.in_ctype .. " *"
  subs.cast_y_as = subs.cast_x_as 

  subs.out_qtype = "I8" -- default assumption
  if ( x:is_eov() ) then 
    local n = x:num_elements()
    if ( n < 127 ) then 
      subs.out_qtype = "I1" 
    elseif ( n < 32767 ) then 
      subs.out_qtype = "I2" 
    elseif ( n < 2147483647 ) then 
      subs.out_qtype = "I4" 
    end
  end
  subs.out_width = cutils.get_width_qtype(subs.out_qtype)
  subs.max_num_in_chunk = x:max_num_in_chunk()
  subs.bufsz = subs.out_width * subs.max_num_in_chunk 
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.cast_out_as = subs.out_ctype .. " *"

  subs.incdir = "OPERATORS/AINB/gen_inc/"
  subs.srcdir = "OPERATORS/AINB/gen_src/"
  subs.incs = { "OPERATORS/AINB/gen_inc/", }
  subs.libs = { "-lgomp", }
  print("RETURNING ")
  return subs
end
return get_idx_by_val_specialize
