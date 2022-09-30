local ffi     = require 'ffi'
local is_in   = require 'Q/UTILS/lua/is_in'
local cutils  = require 'libcutils'

return function (
  f1,
  lb,
  ub,
  optargs
  )
  local subs = {}
  if ( optargs ) then assert(type(optargs) == "table") end 
  --===========================================
  assert(type(f1) == "lVector")
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.max_num_in_chunk ) then 
      assert(type(optargs.max_num_in_chunk) == "number")
      assert(optargs.max_num_in_chunk > 0)
      assert( ( ( optargs.max_num_in_chunk / 64 ) * 64 ) == 
        optargs.max_num_in_chunk )
      subs.max_num_in_chunk = optargs.max_num_in_chunk 
    end 
  end 
  local in_qtype = f1:qtype()
  assert(f1:has_nulls() == false)   -- limitation of current implementation
  --=================================
  assert(type(lb) == "lVector")
  assert(type(ub) == "lVector")
  local lb_qtype = lb:qtype()
  local ub_qtype = ub:qtype()
  assert(is_in(lb_qtype, { "I1", "I2", "I4", "I8", }))
  assert(is_in(ub_qtype, { "I1", "I2", "I4", "I8", }))
  --=================================
  subs.in_qtype = in_qtype
  subs.in_ctype = cutils.str_qtype_to_str_ctype(in_qtype)
  subs.out_qtype = in_qtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)

  subs.f1_cast_as = subs.in_ctype  .. "*" 
  subs.f2_cast_as = subs.out_ctype .. "*" 
  subs.width = cutils.get_width_qtype(subs.out_qtype)
  subs.bufsz = subs.max_num_in_chunk * subs.width
  return subs
end
