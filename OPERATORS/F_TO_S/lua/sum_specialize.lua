local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local Scalar    = require 'libsclr'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local rev_lkp   = require 'Q/UTILS/lua/rev_lkp'
local qconsts   = require 'Q/UTILS/lua/q_consts'

local good_qtypes = rev_lkp({ "B1", "I1", "I2", "I4", "I8", "F4", "F8"})
local i_qtypes = rev_lkp({"B1", "I1", "I2", "I4", "I8"})
local f_qtypes = rev_lkp({"F4", "F8"})

return function (in_qtype)
  assert(type(in_qtype) == "string")
  assert(good_qtypes[in_qtype])

  local subs = {}
  subs.operator = "sum"
  subs.fn = subs.operator .. "_" .. in_qtype
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/sum.tmpl"

  --=====================================
  -- set up args for C code
  
  if ( i_qtypes[in_qtype] ) then 
    subs.args_ctype = "SUM_I_ARGS"
    subs.reduce_qtype ="I8"
  elseif ( f_qtypes[in_qtype] ) then 
    subs.args_ctype = "SUM_F_ARGS"
    subs.reduce_qtype = "F8" 
  else
    -- error(in_qtype)
  end
  subs.reduce_ctype = qconsts.qtypes[subs.reduce_qtype].ctype
  local args = cmem.new({size = ffi.sizeof(subs.args_ctype)})
  args:zero()
  subs.args = ffi.cast(subs.args_ctype .. " *", get_ptr(args))
  --==========
  local getter = function (x)
    assert(x) -- this contains the value into which reduction happens

    local sval = Scalar.new(0, subs.reduce_qtype) -- out_qtype from closure
    local s = ffi.cast("SCLR_REC_TYPE *", sval)
    local key = "val" .. subs.reduce_qtype
    s[0].cdata[key] = x[0].val
    -------------------
    local snum = Scalar.new(0, "I8")
    local s = ffi.cast("SCLR_REC_TYPE *", snum)
    local key = "valI8"
    s[0].cdata[key] = x[0].num
    -------------------
    return sval, snum
  end
  subs.getter = getter
  -- handle B1 as special case 
  if ( in_qtype == "B1" ) then 
    subs.tmpl = nil
    subs.dotc = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/src/sum_B1.c"
    subs.doth = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/inc/sum_B1.h"
    -- TODO
  end
  return subs
end
