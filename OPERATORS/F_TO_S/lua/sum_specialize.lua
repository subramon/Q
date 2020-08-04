local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local Scalar    = require 'libsclr'
local lVector   = require 'Q/RUNTIME/VCTR/lua/lVector'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local rev_lkp   = require 'Q/UTILS/lua/rev_lkp'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local good_qtypes = rev_lkp({ "B1", "I1", "I2", "I4", "I8", "F4", "F8"})
local qc        = require 'Q/UTILS/lua/q_core'

local i_qtypes = rev_lkp({"B1", "I1", "I2", "I4", "I8"})
local f_qtypes = rev_lkp({"F4", "F8"})

qc.q_cdef("OPERATORS/F_TO_S/inc/sum_struct.h", { "UTILS/inc/" })

return function (x, optargs)
  assert(type(x) == "lVector")
  assert(not x:has_nulls())
  local qtype = x:qtype()
  assert(good_qtypes[qtype])

  local subs = {}
  subs.operator = "sum"
  subs.fn = subs.operator .. "_" .. qtype
  subs.ctype = qconsts.qtypes[qtype].ctype
  subs.cst_in_as = subs.ctype .. " *"
  --=====================================
  -- set up args for C code
  --==========
  if ( i_qtypes[qtype] ) then 
    subs.cargs_ctype = "SUM_I_ARGS"
    subs.reduce_qtype ="I8"
  elseif ( f_qtypes[qtype] ) then 
    subs.cargs_ctype = "SUM_F_ARGS"
    subs.reduce_qtype = "F8" 
  else
    error(qtype)
  end
  --==========
  subs.reduce_ctype = qconsts.qtypes[subs.reduce_qtype].ctype
  subs.cargs = cmem.new({size = ffi.sizeof(subs.cargs_ctype)})
  subs.cargs:zero()
  subs.cst_cargs_as = subs.cargs_ctype .. " *"
  --==========
  local getter = function (x)
    assert(type(x) == "CMEM") -- value into which reduction happens
    x = get_ptr(x, subs.cst_cargs_as)

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
  subs.tmpl   = "OPERATORS/F_TO_S/lua/sum.tmpl"
  subs.incdir = "OPERATORS/F_TO_S/gen_inc/"
  subs.srcdir = "OPERATORS/F_TO_S/gen_src/"
  subs.incs = { "UTILS/inc", "OPERATORS/F_TO_S/inc/", "OPERATORS/F_TO_S/gen_inc/", }
  subs.structs = { "OPERATORS/F_TO_S/inc/sum_struct.h", 
                   "RUNTIME/SCLR/inc/scalar_struct.h" }
  -- handle B1 as special case
  if ( qtype == "B1" ) then 
    subs.tmpl = nil
    subs.dotc = "OPERATORS/F_TO_S/src/sum_B1.c"
    subs.doth = "OPERATORS/F_TO_S/inc/sum_B1.h"
    subs.srcs = { "UTILS/src/get_bit_u64.c" }
  end
  return subs
end
