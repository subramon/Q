local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local rev_lkp   = require 'Q/UTILS/lua/rev_lkp'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local good_qtypes = rev_lkp({ "I1", "I2", "I4", "I8", "F4", "F8"})

return function (in_qtype, operator)
  assert(type(operator) == "string")
  assert(type(in_qtype) == "string")
  assert(good_qtypes[in_qtype])
  --====================
  local subs = {}
  subs.fn = operator ..  "_" .. in_qtype 
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.reduce_qtype = in_qtype
  if ( operator == "min" ) then 
    subs.comparator     = " < "
    subs.alt_comparator = " <= "
  elseif ( operator == "max" ) then 
    subs.comparator     = " > "
    subs.alt_comparator = " >= "
  else
    error(operator)
  end
  subs.tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/minmax.tmpl"
  subs.operator = operator -- used by check_subs()
  --=====================================
  -- set up args for C code
  subs.args_ctype = "MINMAX_" .. in_qtype .. "_ARGS";
  local args = cmem.new({size = ffi.sizeof(subs.args_ctype)})
  args:zero()
  subs.args = ffi.cast(subs.args_ctype .. " *", get_ptr(args))
  --==========
  local getter = function (x)
    assert(x) -- this contains the value into which reduction happens

    local sval = Scalar.new(0, subs.reduce_qtype) -- out_qtype from closure
    local s = ffi.cast("SCLR_REC_TYPE *", sval)
    local key = val .. subs.reduce_qtype
    s[0][key] = x[0].val
    -------------------
    local snum = Scalar.new(0, "I8")
    local s = ffi.cast("SCLR_REC_TYPE *", sval)
    s[0]["I8"] = x[0].val
    -------------------
    local sidx = Scalar.new(0, "I8")
    local s = ffi.cast("SCLR_REC_TYPE *", sval)
    s[0]["I8"] = x[0].sidx
    -------------------
    return s1, s2
  end
  subs.getter = getter
  return subs
end
