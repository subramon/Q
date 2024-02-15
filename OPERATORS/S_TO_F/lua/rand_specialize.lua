local cutils    = require 'libcutils'
local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local cutils    = require 'libcutils'
local cVector   = require 'libvctr'
local Scalar    = require 'libsclr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local qc        = require 'Q/UTILS/lua/qcore'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'

-- cdef the necessary struct within pcall to prevent error on second call
local incs = { "RUNTIME/CMEM/inc/", "UTILS/inc/" }
qc.q_cdef("UTILS/inc/drand_struct.h")
qc.q_cdef("OPERATORS/S_TO_F/inc/rand_struct.h", incs)
qc.q_cdef("RUNTIME/SCLR/inc/sclr_struct.h", incs)
return function (
  largs
  )
  --=================================
  assert(type(largs) == "table")
  local qtype = assert(largs.qtype)
  local len   = assert(largs.len)
  assert(is_in(qtype, { "B1", "I1", "I2", "I4", "I8", "F4", "F8"}))
  assert(len > 0, "vector length must be positive")
  --=======================
  local subs = {}
  subs.fn = "rand_" .. qtype
  subs.len = len
  subs.out_qtype = qtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(qtype)
  subs.max_num_in_chunk = get_max_num_in_chunk (largs)
  subs.out_width = cutils.get_width_qtype(qtype)
  subs.buf_size = subs.max_num_in_chunk * subs.out_width
  subs.cast_buf_as = subs.out_ctype .. " * "
  --=======================
  -- set up args for C code
  subs.cargs_ctype = "RAND_" .. qtype .. "_REC_TYPE";
  local sz = ffi.sizeof(subs.cargs_ctype)
  subs.cargs = cmem.new(sz); 
  subs.cargs:zero()
  subs.cast_cargs_as = subs.cargs_ctype .. " *"

  -- set seed
  local seed
  if ( largs.seed ) then 
    seed = largs.seed
  else
    seed = cutils.rdtsc() 
  end
  assert(type(seed) == "number")
  assert(seed > 0)
  --=============
  local sseed = assert(to_scalar(seed, "I8"))
  assert(type(sseed) == "Scalar")
  local sseed = ffi.cast("SCLR_REC_TYPE *", sseed)
  local cargs = assert(get_ptr(subs.cargs, subs.cast_cargs_as))
  cargs[0]["seed"] = sseed[0].val.i8
  --=========================
  --=== handle B1 as special case
  subs.tmpl   = "OPERATORS/S_TO_F/lua/rand.tmpl"
  subs.incdir = "OPERATORS/S_TO_F/gen_inc/"
  subs.srcdir = "OPERATORS/S_TO_F/gen_src/"
  subs.incs = { "UTILS/inc", "OPERATORS/S_TO_F/inc/", "OPERATORS/S_TO_F/gen_inc/", }
  subs.structs = { "OPERATORS/S_TO_F/inc/rand_struct.h" }
  if ( qtype ~= "B1" ) then
    -- set lb
    local lb  = assert(largs.lb)
    local slb = assert(to_scalar(lb, qtype))
    local slb = ffi.cast("SCLR_REC_TYPE *", slb)
    cargs[0]["lb"] = slb[0].val[string.lower(qtype)]
    -- set ub
    local ub   = assert(largs.ub)
    local sub = assert(to_scalar(ub, qtype))
    local sub = ffi.cast("SCLR_REC_TYPE *", sub)
    cargs[0]["ub"] = sub[0].val[string.lower(qtype)]
  
    assert(ub > lb)
    -- Check  lb, ub in range for type done by to_scalar()
  else
    -- set probability
    local probability  = assert(largs.probability)
    local sprobability = assert(to_scalar(probability, "F8"))
    local sprobability = ffi.cast("SCLR_REC_TYPE *", sprobability)
    cargs[0]["probability"] = sprobability[0].val.f8

    subs.tmpl = nil -- this is not generated code 
    subs.dotc = "OPERATORS/S_TO_F/src/rand_B1.c"
    subs.doth = "OPERATORS/S_TO_F/inc/rand_B1.h"
    subs.srcs = { "UTILS/src/rdtsc.c" }
  end
  return subs
end
