local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Scalar  = require 'libsclr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

return function (
  x,
  y,
  z
  )
  local subs = {}
  assert(type(x) == "lVector")
  subs.max_num_in_chunk == x:max_num_in_chunk()
  assert(not x:has_nulls())
  assert(x:fldtype() == "BL") -- TODO P3 Allow B1 as well 

  if ( ( type(y) == "lVector" ) and ( type(z) == "lVector" ) ) then 
    subs.variation = "vv"
    assert(subs.max_num_in_chunk == y:max_num_in_chunk())
    assert(is_base_qtype(y:qtype()))
    assert(not y:has_nulls())

    assert(subs.max_num_in_chunk == z:max_num_in_chunk())
    assert(is_base_qtype(z:qtype()))
    assert(not z:has_nulls())
  elseif ( ( type(y) == "lVector" ) and 
    ( ( type(z) == "Scalar" ) or ( type(z) == "number" ) ) ) then 
    subs.variation = "vs"
    z = assert(Scalar.new(z, y:qtype()))
  elseif ( ( ( type(y) == "Scalar" ) or ( type(y) == "number") ) 
    and ( type(z) == "lVector" ) ) then 
    subs.variation = "sv"
    assert(not z:has_nulls())
    y = assert(Scalar.new(y, z:qtype()))
  elseif ( ( ( type(y) == "Scalar" ) or ( type(y) == "number") ) and
           ( ( type(z) == "Scalar" ) or ( type(z) == "number") ) ) then
    subs.variation = "ss"
    -- TODO 
  else
    error("bad types for ifxthenyelsez")
  end
  --==================================================
  subs.fn = subs.variation .. "_ifxthenyelsez_" .. subs.qtype 
  -- ??? subs.qtype = qtype

  subs.tmpl = "/OPERATORS/IFXTHENYELSEZ/lua/" .. subs.variation .. "_ifxthenyelsez.tmpl"
  subs.incdir = "OPERATORS/IFXTHENYELSEZ/gen_inc/"
  subs.srcdir = "OPERATORS/IFXTHENYELSEZ/gen_src/"
  subs.incs = { "OPERATORS/IFXTHENYELSEZ/gen_inc/" }
  return subs
end
