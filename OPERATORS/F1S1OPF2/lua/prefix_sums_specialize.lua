local cutils = require 'libcutils'
local is_in  = require 'RSUTILS/lua/is_in'
return function (
  f1,
  s1,
  optargs
  )
  local subs = {}
  assert(type(f1) == "lVector")
  -- no scalar for prefix sums 

  subs.f1_qtype = f1:qtype()
  subs.f1_ctype   = cutils.str_qtype_to_str_ctype(subs.f1_qtype)
  subs.cast_f1_as  = subs.f1_ctype .. " *"

  if (is_in(subs.f1_qtype, { "I1", "I2", "I4", "I8", })) then
    subs.f2_qtype = "I8"
  elseif (is_in(subs.f1_qtype, { "UI1", "UI2", "UI4", "UI8", })) then
    subs.f2_qtype = "UI8"
  elseif (is_in(subs.f1_qtype, { "F4", "F8", })) then
    subs.f2_qtype = "F8"
  else
    error("bad input type")
  end
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.out_qtype ) then 
      assert(type(ptargs.out_qtype) == "string")
      subs.f2_qtype = optargs.out_qtype
      assert(is_in(subs.f2_qtype, 
      { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", "F4", "F8", }))
    end
  end
  subs.f2_ctype = cutils.str_qtype_to_str_ctype(subs.f2_qtype)
  subs.cast_f2_as  = subs.f2_ctype .. " *"

  subs.max_num_in_chunk = f1:max_num_in_chunk()
  local width = cutils.get_width_qtype(subs.f2_qtype)
  subs.bufsz = width * subs.max_num_in_chunk
  --===============
  subs.fn = "prefix_sums_" .. subs.f1_qtype .. "_" .. subs.f2_qtype
  subs.tmpl      = "OPERATORS/F1S1OPF2/lua/prefix_sums.tmpl"
  subs.srcdir    = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir    = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", }

  return subs
end
