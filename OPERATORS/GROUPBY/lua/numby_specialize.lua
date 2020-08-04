local qconsts   = require 'Q/UTILS/lua/q_consts'
local is_in     = require 'Q/UTILS/lua/is_in'
local in_qtypes = { 'I1', 'I2', 'I4', 'I8' }

return function (
  a, 
  nb,
  optargs
  )
  local subs = {};

  assert(type(a) == "lVector")
  assert(not a:has_nulls())
  local in_qtype = a:qtype()
  assert(is_in(in_qtype, in_qtypes))
  --========================================
  if ( type(nb) == "Scalar") then nb = nb:to_num() end 
  assert(type(nb) == "number")
  assert( ( nb > 1) and ( nb < 1024) )
  subs.nb = nb 
  --========================================
  -- Keeping default is_safe value as true
  -- This will not allow C code to write values at incorrect locations
  local is_safe = true
  if optargs then
    assert(type(optargs) == "table")
    if ( optargs["is_safe"] == false ) then
      is_safe =  optargs["is_safe"]
      assert(type(is_safe) == "boolean")
    end
  end
  subs.is_safe = is_safe
  --========================================

  subs.in_qtype = in_qtype
  subs.in_ctype = assert(qconsts.qtypes[subs.in_qtype].ctype)
  subs.cst_in_as = subs.in_ctype .. " *"

  subs.out_qtype = "I8"
  subs.out_ctype = assert(qconsts.qtypes[subs.out_qtype].ctype)
  subs.cst_out_as = subs.out_ctype .. " *"

  subs.fn = "numby_" .. in_qtype 
  subs.checking_code = " /* No checks made on value */ "
  subs.bye = " "
  if ( is_safe ) then 
    subs.fn = "numby_safe_" .. in_qtype 
    subs.checking_code = 
    " if ( ( x < 0 ) || ( (uint32_t)x >= nZ ) ) { go_BYE(-1); } "
    subs.bye = "BYE: "
  end
  subs.tmpl   = "OPERATORS/GROUPBY/lua/numby.tmpl"
  subs.srcdir = "OPERATORS/GROUPBY/gen_src/"
  subs.incdir = "OPERATORS/GROUPBY/gen_inc/"
  subs.incs   = { "OPERATORS/GROUPBY/gen_inc/", "UTILS/inc/" }
  return subs
end
