local cutils = require 'libcutils'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

local function get_idx_by_val_specialize(x, y, optargs)
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
  local search_type
  if ( y:get_meta("sort_order") == "asc" ) then
    search_type = "binary"
  else
    search_type = "linear"
  end

  local F = {}
  F[#F+1] = "get_idx_by_val_"
  F[#F+1] = search_type
  F[#F+1] = "_search_" 
  F[#F+1] = x:qtype()
  subs.fn = table.concat(F, "")
  local F = {}
  F[#F+1] = "OPERATORS/AINB/lua/get_idx_by_val_" 
  F[#F+1] = search_type
  F[#F+1] = "_search.tmpl"
  subs.tmpl = table.concat(F, "")
  --== We can gain some extra efficiency if we know that all values
  -- of x are in y
  local all_x_in_y = false
  if ( optargs ) then
    assert(type(optargs) == "table")
    local b = optargs.all_x_in_y
    if ( b ) then 
      assert(type(b) == "boolean")
      all_x_in_y = b
    end
  end
  if ( all_x_in_y ) then
    subs.out_has_nulls = false
  else
    subs.out_has_nulls = true
  end
  --==================================================

  subs.in_ctype = cutils.str_qtype_to_str_ctype(subs.in_qtype)
  subs.cast_x_as = subs.in_ctype .. " *"
  subs.cast_y_as = subs.cast_x_as 

  local n = y:num_elements()
  if ( n < 127 ) then 
    subs.out_qtype = "I1" 
  elseif ( n < 32767 ) then 
    subs.out_qtype = "I2" 
  else 
    error("You should not be using this function")
  end
  --================================================
  subs.out_width = cutils.get_width_qtype(subs.out_qtype)
  subs.max_num_in_chunk = x:max_num_in_chunk()
  subs.out_bufsz = subs.out_width * subs.max_num_in_chunk 
  subs.nn_bufsz = 1 * subs.max_num_in_chunk  -- using BL for now 
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.cast_out_as = subs.out_ctype .. " *"

  subs.omp_chunk_size = 1024 
  subs.incdir = "OPERATORS/AINB/gen_inc/"
  subs.srcdir = "OPERATORS/AINB/gen_src/"
  subs.incs = { "OPERATORS/AINB/gen_inc/", }
  subs.libs = { "-lgomp", }
  return subs
end
return get_idx_by_val_specialize
