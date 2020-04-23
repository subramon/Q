local cutils  = require 'libcutils'
local qconsts = require 'Q/UTILS/lua/q_consts'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local variations = { vv = true, vs = true, sv = true, ss = true }
local oktypes = {}
oktypes["I1"] = true
oktypes["I2"] = true
oktypes["I4"] = true
oktypes["I8"] = true
oktypes["F4"] = true
oktypes["F8"] = true

return function (
  variation,
  x,
  y,
  z
  )
  assert(variations[variation])
  assert(type(x) == "lVector")
  assert(not x:has_nulls())
  assert(x:fldtype() == "B1")
  local subs = {}

  if ( variation == "vv" ) then 
    assert(type(y) == "lVector")
    assert(not y:has_nulls())
    assert(type(z) == "lVector")
    assert(not z:has_nulls())
  elseif ( variation == "vs" ) then 
    assert(type(y) == "lVector")
    assert(not y:has_nulls())
    assert(type(z) == "Scalar")
    assert(z:fldtype() == y:fldtype())
  elseif ( variation == "sv" ) then 
    assert(type(y) == "Scalar")
    assert(type(z) == "lVector")
    assert(y:fldtype() == z:fldtype())
    assert(not z:has_nulls())
  elseif ( variation == "ss" ) then 
    assert(type(y) == "Scalar")
    assert(type(z) == "Scalar")
    assert(y:fldtype() == z:fldtype())
  else
    error("")
  end
  subs.qtype = y:fldtype()
  assert(oktypes[subs.qtype], subs.qtype)
  subs.ctype = qconsts.qtypes[subs.qtype].ctype

  local tmpl = qconsts.Q_SRC_ROOT	 .. "/OPERATORS/IFXTHENYELSEZ/lua/" .. variation .. "_ifxthenyelsez.tmpl"
  assert(cutils.isfile(tmpl))

  subs.fn = variation .. "_ifxthenyelsez_" .. subs.qtype 
  subs.qtype = qtype
  subs.tmpl = tmpl
  return subs
end
