local cutils        = require 'libcutils'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local lVector       = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'

return function (a, b, optargs)
  local subs = {}; 
  assert(type(a) == "lVector")
  local a_qtype = a:qtype()
  assert(a:max_num_in_chunk() > 0)
  local max_num_in_chunk = a:max_num_in_chunk()
  assert(is_base_qtype(a_qtype))
  assert(not a:has_nulls()) -- TODO P4 For later 

  assert(type(b) == "lVector")
  local b_qtype = b:qtype()
  assert( (b_qtype == "BL") or (b_qtype == "B1"))
  assert(not b:has_nulls())
  assert(b:max_num_in_chunk() > 0)
  print("XXXXXX", b:max_num_in_chunk(), max_num_in_chunk)
  assert(b:max_num_in_chunk() == max_num_in_chunk)

  subs.fn      = "where_" .. a_qtype .. "_" .. b_qtype 
  subs.srcdir  = "OPERATORS/WHERE/gen_src/"
  subs.incdir  = "OPERATORS/WHERE/gen_inc/"
  subs.incs    = { "OPERATORS/WHERE/gen_inc/", "UTILS/inc/" }
  subs.srcs    = { "UTILS/src/get_bit_u64.c" }
  subs.a_qtype = a_qtype
  subs.b_qtype = b_qtype
  subs.a_ctype = cutils.str_qtype_to_str_ctype(a_qtype)
  subs.tmpl    = "OPERATORS/WHERE/lua/where_" .. b_qtype .. ".tmpl"

  local width = cutils.get_width_qtype(a_qtype)
  subs.max_num_in_chunk = get_max_num_in_chunk(optargs)
  subs.size = width * subs.max_num_in_chunk
  subs.cast_a_as   = cutils.str_qtype_to_str_ctype(a_qtype) .. "*"
  subs.cast_b_as   = cutils.str_qtype_to_str_ctype(b_qtype) .. "*"

  return subs
end
