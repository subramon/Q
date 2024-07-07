local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local Scalar  = require 'libsclr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

-- w := if x then y else z 
return function (
  x,
  y,
  z
  )
  local subs = {}
  assert(type(x) == "lVector")
  subs.max_num_in_chunk = x:max_num_in_chunk()
  -- TODO P1 Think assert(not x:has_nulls())
  assert(subs.max_num_in_chunk > 0)

  local xqtype = x:qtype()
  assert((x:qtype() == "BL") or (x:qtype() == "B1"))
  subs.xqtype = xqtype
  if ( xqtype =="B1" ) then
    subs.cast_x_as = "uint64_t *"
  elseif ( xqtype =="BL" ) then
    subs.cast_x_as = "bool *"
  else
    error("bad xqtype")
  end
  --======================================================
  subs.has_nulls = false
  if ( ( type(y) == "lVector" ) and ( type(z) == "lVector" ) ) then 
    subs.variation = "vv"
    assert(subs.max_num_in_chunk == y:max_num_in_chunk())
    assert(is_base_qtype(y:qtype()))
    subs.yctype = cutils.str_qtype_to_str_ctype(y:qtype())
    subs.cast_y_as = subs.yctype .. "  *"

    assert(subs.max_num_in_chunk == z:max_num_in_chunk())
    assert(is_base_qtype(z:qtype()))
    subs.zctype = cutils.str_qtype_to_str_ctype(z:qtype())
    subs.cast_z_as = subs.zctype .. "  *"

    assert(y:qtype() == z:qtype())
    subs.wqtype = y:qtype()

    if ( ( y:has_nulls() ) or ( z:has_nulls() ) ) then 
      subs.has_nulls = true
    end
  elseif ( ( type(y) == "lVector" ) and 
    ( ( type(z) == "Scalar" ) or ( type(z) == "number" ) 
      or (type(z) == "boolean" ) ) ) then 
    subs.variation = "vs"
    subs.yctype = cutils.str_qtype_to_str_ctype(y:qtype())
    subs.cast_y_as = subs.yctype .. "  *"

    if ( ( type(z) == "number" ) or ( type(z) == "boolean" ) ) then 
      z = assert(Scalar.new(z, y:qtype()))
    end
    assert(y:qtype() == z:qtype())
    subs.wqtype = y:qtype()
    if ( y:has_nulls() ) then 
      subs.has_nulls = true
    end
  elseif ( ( ( type(y) == "Scalar" ) or ( type(y) == "number") 
    or ( type(y) == "boolean") ) 
    and ( type(z) == "lVector" ) ) then 
    subs.variation = "sv"
    subs.zctype = cutils.str_qtype_to_str_ctype(z:qtype())
    subs.cast_z_as = subs.zctype .. "  *"

    if ( ( type(y) == "number" ) or ( type(y) == "boolean") ) then 
      y = assert(Scalar.new(y, z:qtype()))
    end
    assert(y:qtype() == z:qtype())
    subs.wqtype = y:qtype()
    if ( z:has_nulls() ) then 
      subs.has_nulls = true
    end

  elseif ( ( ( type(y) == "Scalar" ) or ( type(y) == "number") 
    or ( type(y) == "boolean") ) and
           ( ( type(z) == "Scalar" ) or ( type(z) == "number") 
           or ( type(z) == "boolean" ) ) ) then
    subs.variation = "ss"
    if     ( ( type(y) == "Scalar" ) and ( type(z) == "Scalar" ) ) then 
      assert(y:qtype() == z:qtype())
      subs.wqtype = y:qtype()
    elseif ( ( type(y) == "Scalar" ) and 
      ( ( type(z) == "number" ) or ( type(z) == "boolean" ) ) ) then 
      z = assert(Scalar.new(z, y:qtype()))
      subs.wqtype = y:qtype()
    elseif ( (( type(y) == "boolean") or ( type(y) == "number" ) ) and 
        ( type(z) == "Scalar" ) ) then 
      y = assert(Scalar.new(y, z:qtype()))
      subs.wqtype = z:qtype()
    elseif ( ( ( type(y) == "boolean") or ( type(y) == "number" ) ) and 
       ( ( type(z) == "boolean") or ( type(z) == "number" ) ) ) then
      y = assert(Scalar.new(y, "F8"))
      z = assert(Scalar.new(z, "F8"))
      subs.wqtype = "F8"
    else
      error("")
    end
  else
    print("type(y) = ", type(y), "type(z) = ", type(z))
    error("bad types for ifxthenyelsez")
  end
  --==================================================
  subs.wctype = cutils.str_qtype_to_str_ctype(subs.wqtype)
  subs.wbufsz = subs.max_num_in_chunk * 
    cutils.get_width_qtype(subs.wqtype)
  subs.cast_w_as = subs.wctype .. "  *"

  subs.nn_wqtype = "BL" -- B1 not supported as yet 
  subs.nn_wctype = cutils.str_qtype_to_str_ctype(subs.nn_wqtype)
  subs.nn_wbufsz = subs.max_num_in_chunk * 
    cutils.get_width_qtype(subs.nn_wqtype)
  subs.cast_nn_w_as = subs.nn_wctype .. "  *"
  --==================================================
  subs.fn = subs.variation .. "_ifxthenyelsez_" .. subs.wqtype 
    .. "_" .. subs.xqtype 

  subs.tmpl = "OPERATORS/IFXTHENYELSEZ/lua/" .. 
    subs.variation .. "_ifxthenyelsez_" .. subs.xqtype .. ".tmpl"
  subs.incdir = "OPERATORS/IFXTHENYELSEZ/gen_inc/"
  subs.srcdir = "OPERATORS/IFXTHENYELSEZ/gen_src/"
  subs.incs = { "OPERATORS/IFXTHENYELSEZ/gen_inc/", "UTILS/inc/", }
  return subs
end
