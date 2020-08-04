local qconsts       = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local lVector       = require 'Q/RUNTIME/VCTR/lua/lVector'
return function (
  a,
  b
  )
  local subs = {}; 
  assert(type(a) == "lVector")
  local a_qtype = a:qtype()
  assert(is_base_qtype(a_qtype))
  assert(not a:has_nulls())

  assert(type(b) == "lVector")
  assert(b:qtype() == "B1")
  assert(not b:has_nulls())

  subs.fn = "where_" .. a_qtype
  subs.srcdir = "OPERATORS/WHERE/gen_src/"
  subs.incdir = "OPERATORS/WHERE/gen_inc/"
  subs.incs = { "OPERATORS/WHERE/gen_inc/", "UTILS/inc/" }
  subs.srcs = { "UTILS/src/get_bit_u64.c" }
  subs.a_ctype = qconsts.qtypes[a_qtype].ctype
  subs.tmpl = "OPERATORS/WHERE/lua/where.tmpl"
  return subs
end
