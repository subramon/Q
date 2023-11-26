local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local cutils    = require 'libcutils'
local Scalar    = require 'libsclr'
local lVector   = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local rev_lkp   = require 'Q/UTILS/lua/rev_lkp'
local qcfg      = require 'Q/UTILS/lua/qcfg'
local qc        = require 'Q/UTILS/lua/qcore'
local is_in     = require 'Q/UTILS/lua/is_in'

local i_qtypes = {"BL", "B1", "I1", "I2", "I4", "I8"}
local f_qtypes = {"F4", "F8"}
local good_qtypes = { "BL", "B1", "I1", "I2", "I4", "I8", "F4", "F8"}

qc.q_cdef("OPERATORS/F_TO_S/inc/sum_struct.h", { "UTILS/inc/" })

return function (x, optargs)
  assert(type(x) == "lVector")
  assert(x:has_nulls() == false) -- TODO P4 Relax this assumption
  local qtype = x:qtype()
  assert(is_in(qtype, good_qtypes))

  local subs = {}
  subs.operator   = "sum"
  subs.fn         = subs.operator .. "_" .. qtype -- e.g., sum_F4
  subs.ctype      = cutils.str_qtype_to_str_ctype(qtype) -- e.g., float
  subs.cast_in_as = subs.ctype .. " *" -- e.g., "float *"
  subs.max_num_in_chunk = assert(x:max_num_in_chunk())
  --=====================================
  -- set up args for C code
  --==========
  -- When we query the Reduce for a value, we return 2 values
  -- These are (1) the sum (2) the number of values seen
  -- (2) need not be the same as number of elements because one can ask
  -- for partial values -- num_seen is  of type I8
  -- sum has type F8  or I8
  if ( is_in(qtype, i_qtypes) ) then 
    subs.accumulator_ctype = "SUM_I_ARGS"
    subs.reduce_qtype ="I8"
    subs.reduce_ctype ="int64_t"
  elseif ( is_in(qtype, f_qtypes) ) then 
    subs.accumulator_ctype = "SUM_F_ARGS"
    subs.reduce_qtype = "F8" 
    subs.reduce_ctype ="double"
  else
    error(qtype)
  end
  --==========
  local sz = ffi.sizeof(subs.accumulator_ctype)
  subs.accumulator = cmem.new(sz)
  subs.accumulator:zero()
  subs.cast_accumulator_as = subs.accumulator_ctype .. " *"
  --==========
  local getter = function (x)
    -- x is where the Reducer saves partial values
    -- Purpose of this function is to take x and return 3 Scalars
    -- (1) is for the value that has been computed
    -- TODO TODO -- (2) the number of values that have been consumed
    -- (3) the number of values that have been seen
    -- Note that (2) and (3) might be different because of null values
    assert(type(x) == "CMEM") -- value into which reduction happens
    assert(x:is_data())
    x = get_ptr(x, subs.cast_accumulator_as)

    local outval = Scalar.new(0, subs.reduce_qtype) --out_qtype from closure
    local tmps = ffi.cast("SCLR_REC_TYPE *", outval)
    local key = string.lower(subs.reduce_qtype)
    tmps[0].val[key] = x[0].val
    -------------------
    local num_seen = Scalar.new(0, "I8")
    local tmps = ffi.cast("SCLR_REC_TYPE *", num_seen)
    tmps[0].val.i8 = x[0].num
    -------------------
    return outval, num_seen
  end
  subs.getter = getter
  subs.tmpl   = "OPERATORS/F_TO_S/lua/sum.tmpl"
  subs.incdir = "OPERATORS/F_TO_S/gen_inc/"
  subs.srcdir = "OPERATORS/F_TO_S/gen_src/"
  subs.incs = { "UTILS/inc", "OPERATORS/F_TO_S/inc/", "OPERATORS/F_TO_S/gen_inc/", }
  subs.structs = { "OPERATORS/F_TO_S/inc/sum_struct.h", 
                   "RUNTIME/SCLR/inc/sclr_struct.h" }
  -- handle B1 as special case
  if ( qtype == "B1" ) then 
    subs.tmpl = nil
    subs.dotc = "OPERATORS/F_TO_S/src/sum_B1.c"
    subs.doth = "OPERATORS/F_TO_S/inc/sum_B1.h"
    subs.srcs = { "UTILS/src/get_bit_u64.c" }
  end
  return subs
end
