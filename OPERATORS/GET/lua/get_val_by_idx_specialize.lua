local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_int_qtype = require 'Q/UTILS/lua/is_int_qtype'
local cutils    = require 'libcutils'

return function (val, idx, optargs)
  local subs = {}
  assert(type(val) == "lVector")
  subs.val_qtype = val:qtype()
  assert(subs.val_qtype ~= "SC")
  assert(subs.val_qtype ~= "TM")
  assert(type(idx) == "lVector")
  subs.idx_qtype = idx:qtype()
  assert(is_int_qtype(subs.idx_qtype))

  assert(idx:has_nulls() == false) -- TODO P4 relax
  assert(val:has_nulls() == false) -- TODO P4 relax

  if ( val:is_eov() == false ) then val:eval() end 
  if ( val:is_lma() == false ) then val:chunks_to_lma() end 

  subs.val_ctype = cutils.str_qtype_to_str_ctype(subs.val_qtype)
  subs.cast_val_as = subs.val_ctype .. " *"

  subs.idx_ctype = cutils.str_qtype_to_str_ctype(subs.idx_qtype)
  subs.cast_idx_as = subs.idx_ctype .. " *"

  subs.out_qtype = subs.val_qtype
  subs.out_ctype = subs.val_ctype
  subs.cast_out_as = subs.cast_val_as

  local all_vals_good = false -- default 
  subs.out_has_nulls = true -- default 
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.all_values_good ) then 
      assert(type(optargs.all_values_good) == "boolean")
      all_vals_good = optargs.all_values_good
    end
  end
  if ( all_vals_good == false ) then 
    subs.nn_out_val_qtype = "BL"
    subs.nn_out_val_ctype = "bool"
    subs.cast_nn_val_as   = "bool *"
  else
    subs.out_has_nulls = false
  end

  subs.width = cutils.get_width_qtype(subs.out_qtype)
  subs.max_num_in_chunk = idx:max_num_in_chunk()
  subs.out_bufsz = subs.width * subs.max_num_in_chunk 

  subs.nn_out_bufsz = subs.max_num_in_chunk
  subs.nn_out_qtype = "BL"
  subs.cast_nn_out_as = "bool *"

  subs.omp_chunk_size = 512;
  subs.fn = "get_val_" .. subs.val_qtype .. "_by_idx_" .. subs.idx_qtype 
  subs.tmpl   = "OPERATORS/GET/lua/get_val_by_idx.tmpl"
  subs.incdir = "OPERATORS/GET/gen_inc/"
  subs.srcdir = "OPERATORS/GET/gen_src/"
  subs.incs = { "OPERATORS/GET/gen_inc/", "UTILS/inc/" }

  return subs
end
