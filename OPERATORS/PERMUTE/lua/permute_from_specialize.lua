local cutils  = require 'libcutils'
local lgutils = require 'liblgutils'
local is_in   = require 'RSUTILS/lua/is_in'

local function permute_from_specialize(invec, p, optargs)
  local subs = {}

  if ( optargs ) then assert(type(optargs) == "table") end 
  assert(type(invec) == "lVector")
  assert(type(p) == "lVector")

  assert(not p:has_nulls())
  if ( invec:is_lma() == false ) then
    invec:chunks_to_lma()
  end


  subs.num_elements = invec:num_elements()
  subs.val_width  = invec:width()
  subs.val_qtype  = invec:qtype()
  subs.perm_qtype = p:qtype()

  subs.max_num_in_chunk = p:max_num_in_chunk()
  subs.bufsz = subs.max_num_in_chunk * subs.val_width
  assert(subs.bufsz > 0)

  subs.val_ctype  = cutils.str_qtype_to_str_ctype(subs.val_qtype)
  assert(subs.val_ctype) 

  subs.perm_ctype = cutils.str_qtype_to_str_ctype(subs.perm_qtype)
  assert(subs.perm_ctype) 

  subs.cast_x_as = "const " .. subs.val_ctype .. " * const"
  subs.cast_y_as = subs.val_ctype .. " *"
  subs.cast_p_as = subs.perm_ctype .. " *"

  if ( subs.num_elements <= 127 ) then 
    assert(is_in(subs.perm_qtype, { "I1", "I2", "I4", "I8" }))
  elseif ( subs.num_elements <= 32767 ) then 
    assert(is_in(subs.perm_qtype, { "I1", "I2", "I4", "I8" }))
  elseif ( subs.num_elements <= 2147483647 ) then 
    assert(is_in(subs.perm_qtype, { "I4", "I8" }))
  else
    assert(is_in(subs.perm_qtype, { "I8" }))
  end

  subs.file_name = "_permute_from_" .. (cutils.rdtsc() % 2^32)-- some temp name 
  subs.dir_name  = lgutils.data_dir()
  subs.file_sz   = subs.val_width * subs.num_elements
  --========================================
  subs.fn = "permute_from_" .. subs.val_qtype .. "_" .. subs.perm_qtype

  subs.tmpl   = "OPERATORS/PERMUTE/lua/permute_from.tmpl"
  subs.incdir = "OPERATORS/PERMUTE/gen_inc/"
  subs.srcdir = "OPERATORS/PERMUTE/gen_src/"
  subs.incs = { "UTILS/inc/", "OPERATORS/PERMUTE/gen_inc/" }

  --========================================
  -- Now deal with nulls in input vector if any
  local nn_subs 
  if ( invec:has_nulls() ) then 
    subs.has_nulls = true -- IMPORTANT
    nn_subs = {}
    assert(invec:nn_qtype() == "BL")
    nn_subs.val_qtype = "BL"
    nn_subs.val_ctype = "bool"
    nn_subs.cast_as = "bool *"
    nn_subs.bufsz = subs.max_num_in_chunk 
    nn_subs.perm_qtype = subs.perm_qtype
    nn_subs.perm_ctype = subs.perm_ctype
    nn_subs.fn = "permute_from_BL_" .. subs.perm_qtype

    nn_subs.tmpl   = "OPERATORS/PERMUTE/lua/permute_from.tmpl"
    nn_subs.incdir = "OPERATORS/PERMUTE/gen_inc/"
    nn_subs.srcdir = "OPERATORS/PERMUTE/gen_src/"
    nn_subs.incs = { "UTILS/inc/", "OPERATORS/PERMUTE/gen_inc/" }
  end
  --========================================
  return subs, nn_subs
end
return permute_from_specialize

