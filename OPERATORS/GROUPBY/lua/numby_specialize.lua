local cutils = require 'libcutils'
local is_in     = require 'Q/UTILS/lua/is_in'
local in_qtypes = { 'I1', 'I2', 'I4', 'I8' }
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'

return function (
  a, 
  nb,
  optargs
  )
  local subs = {};

  assert(type(a) == "lVector")
  assert(a:has_nulls() == false)
  subs.in_qtype = a:qtype()
  assert(is_in(subs.in_qtype, in_qtypes))
  --========================================
  if ( type(nb) == "Scalar") then nb = nb:to_num() end 
  assert(type(nb) == "number")
  subs.max_num_in_chunk = get_max_num_in_chunk(optargs)
  assert( ( nb >= 1 ) and ( nb <= subs.max_num_in_chunk ) )
  subs.nb = nb 
  --========================================
  -- Keeping default is_safe value as true
  -- This will not allow C code to write values at incorrect locations
  subs.is_safe = true
  if optargs then
    assert(type(optargs) == "table")
    if ( optargs["is_safe"] == false ) then
      subs.is_safe = false
    end
  end
  --========================================

  subs.in_ctype = cutils.str_qtype_to_str_ctype(subs.in_qtype)
  subs.cast_in_as = subs.in_ctype .. " *"

  subs.out_qtype = "I8"
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.cast_out_as = subs.out_ctype .. " *"

  subs.fn = "numby_" .. subs.in_qtype 
  if ( subs.is_safe == false ) then subs.fn = subs.fn .. "_unsafe" end

  if ( subs.is_safe ) then 
    subs.checking_code = 
    " if ( ( x < 0 ) || ( (uint32_t)x >= nZ ) ) { go_BYE(-1); } "
    subs.bye = "BYE: "
  else
    subs.fn = subs.fn .. "_unsafe" 
    subs.checking_code = " /* No checks made on value */ "
    subs.bye = " "
  end
  subs.tmpl   = "OPERATORS/GROUPBY/lua/numby.tmpl"
  subs.srcdir = "OPERATORS/GROUPBY/gen_src/"
  subs.incdir = "OPERATORS/GROUPBY/gen_inc/"
  subs.incs   = { "OPERATORS/GROUPBY/gen_inc/", "UTILS/inc/" }
  return subs
end
