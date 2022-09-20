local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local cutils    = require 'libcutils'
local Scalar    = require 'libsclr'
local lVector   = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local rev_lkp   = require 'Q/UTILS/lua/rev_lkp'
local qcfg      = require 'Q/UTILS/lua/qcfg'
local good_qtypes = rev_lkp({ "BL", "B1", "I1", "I2", "I4", "I8", "F4", "F8"})
local qc        = require 'Q/UTILS/lua/qcore'

local i_qtypes = rev_lkp({"BL", "B1", "I1", "I2", "I4", "I8"})
local f_qtypes = rev_lkp({"F4", "F8"})

qc.q_cdef("OPERATORS/F_TO_S/inc/sum_struct.h", { "UTILS/inc/" })

return function (x, optargs)
  assert(type(x) == "lVector")
  assert(x:has_nulls() == false) -- TODO P4 Relax this assumption
  local qtype = x:qtype()
  assert(good_qtypes[qtype])

  local subs = {}
  subs.operator   = "sum"
  subs.fn         = subs.operator .. "_" .. qtype -- e.g., sum_F4
  subs.ctype      = cutils.str_qtype_to_str_ctype(qtype) -- e.g., float
  subs.cast_in_as = subs.ctype .. " *" -- e.g., "float *"
  --=====================================
  -- set up args for C code
  --==========
  -- When we query the Reduce for a value, we return 3 values
  -- These are (1) the sum (2) the number of values seen
  -- (3) the number of values that were good
  -- (2) need not be the same as number of elements because one can ask
  -- for partial values
  -- (2) need not be the same as (3) when there are null values
  -- We call these 3 values  (a) outval (b) num_seen (c) num_good
  -- num_seen and num_good are of type I8
  -- outval has type F8  or I8
  if ( i_qtypes[qtype] ) then 
    subs.accumulator_ctype = "SUM_I_ARGS"
    subs.outval_qtype ="I8"
    subs.outval_ctype ="int64_t"
  elseif ( f_qtypes[qtype] ) then 
    subs.accumulator_ctype = "SUM_F_ARGS"
    subs.outval_qtype = "F8" 
    subs.outval_ctype ="double"
  else
    error(qtype)
  end
  --==========
  subs.accumulator = cmem.new({size = ffi.sizeof(subs.accumulator_ctype)})
  subs.accumulator:zero()
  subs.cast_accumulator_as = subs.accumulator_ctype .. " *"
  --==========
  local getter = function (x)
    -- x is where the Reducer saves partial values
    -- Purpose of this function is to take x and return 3 Scalars
    -- (1) is for the value that has been computed
    -- (2) the number of values that have been consumed
    -- (3) the number of values that have been seen
    -- Note that (2) and (3) might be different because of null values
    assert(type(x) == "CMEM") -- value into which reduction happens
    assert(x:is_data())
    x = get_ptr(x, subs.cast_accumulator_as)

    local outval = Scalar.new(0, subs.outval_qtype) --out_qtype from closure
    local tmps = ffi.cast("SCLR_REC_TYPE *", outval)
    local key = string.lower(subs.outval_qtype)
    tmps[0].val[key] = x[0].val
    -------------------
    local num_seen = Scalar.new(0, "I8")
    local tmps = ffi.cast("SCLR_REC_TYPE *", num_seen)
    tmps[0].val.i8 = x[0].num
    -------------------
    local num_good = Scalar.new(0, "I8")
    local tmps = ffi.cast("SCLR_REC_TYPE *", num_good)
    tmps[0].val.i8 = x[0].num_good
    -------------------
    return outval, num_seen, num_good
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
