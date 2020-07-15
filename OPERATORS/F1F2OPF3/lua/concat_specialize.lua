local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
return function (
  f1, 
  f2, 
  optargs
  )
  assert(type(f1) == "lVector")
  assert(type(f2) == "lVector")
  assert(not f1:has_nulls())
  assert(not f2:has_nulls())
  local f1_qtype = f1:qtype()
  local f2_qtype = f2:qtype()
  local plfile = require "pl.file"
  local f3_qtype 
  if ( optargs ) then
    assert(type(optargs) == "table")
    f3_qtype = optargs.f3_qtype -- okay for f3_qtype to be nil
  end
  local ok_intypes = { I1 = true, I2 = true, I4 = true }
  local ok_f3_qtypes = { I2 = true, I4 = true, I8 = true }

  assert(ok_intypes[f1_qtype], "input type " .. f1_qtype .. " not acceptable")
  assert(ok_intypes[f2_qtype], "input type " .. f2_qtype .. " not acceptable")

  local w1   = assert(qconsts.qtypes[f1_qtype].width)
  local w2   = assert(qconsts.qtypes[f2_qtype].width)

  local shift = w2 * 8 -- convert bytes to bits 
  local l_f3_qtype = nil
  if ( f1_qtype == "I4" ) then 
    l_f3_qtype = "I8"
  elseif( f1_qtype == "I2" ) then 
    if ( f2_qtype == "I4" ) then
      l_f3_qtype = "I8"
    elseif( f2_qtype == "I2" ) then
      l_f3_qtype = "I4"
    elseif( f2_qtype == "I1" ) then
      l_f3_qtype = "I4"
    end
  elseif( f1_qtype == "I1" ) then 
    if ( f2_qtype == "I4" ) then
      l_f3_qtype = "I8"
    elseif( f2_qtype == "I2" ) then
      l_f3_qtype = "I4"
    elseif( f2_qtype == "I1" ) then
      l_f3_qtype = "I2"
    end
  end
  assert(l_f3_qtype, "Control should never come here")
  assert(ok_f3_qtypes[l_f3_qtype], "output type " .. 
  l_f3_qtype .. " not acceptable")
  if ( f3_qtype ) then 
    assert(ok_f3_qtypes[f3_qtype], "output type " ..
    f3_qtype .. " not acceptable")
    local width_l_f3_qtype = assert(qconsts.qtypes[l_f3_qtype].width, "ERROR")
    local width_f3_qtype   = assert(qconsts.qtypes[f3_qtype].width, "ERROR")
    assert( width_f3_qtype >= width_l_f3_qtype,
    "specfiied outputtype not big enough")
    l_f3_qtype = f3_qtype
  end
  local subs = {}
  -- This includes is just as a demo. Not really needed
  subs.fn = 
  "concat_" .. f1_qtype .. "_" .. f2_qtype .. "_" .. l_f3_qtype 
  subs.f1_ctype = "u" .. qconsts.qtypes[f1_qtype].ctype
  subs.f2_ctype = "u" .. qconsts.qtypes[f2_qtype].ctype
  subs.f3_qtype = l_f3_qtype
  subs.f3_ctype = "u" .. qconsts.qtypes[l_f3_qtype].ctype

  subs.f1_cast_as = subs.f1_ctype .. "*"
  subs.f2_cast_as = subs.f2_ctype .. "*"
  subs.f3_cast_as = subs.f3_ctype .. "*"

  -- Note that we are movint int8_t to uint8_t below
  subs.c_code_for_operator = " c = ((" .. subs.f3_ctype .. ")a << " .. shift .. " ) | b; "

  subs.tmpl = "OPERATORS/F1F2OPF3/lua/f1f2opf3.tmpl"
  subs.incdir = "OPERATORS/F1F2OPF3/gen_inc/"
  subs.srcdir = "OPERATORS/F1F2OPF3/gen_src/"
  subs.incs = { "OPERATORS/F1F2OPF3/gen_inc/", "UTILS/inc/"}
  return subs
end
