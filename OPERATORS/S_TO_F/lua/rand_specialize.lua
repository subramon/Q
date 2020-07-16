local cutils    = require 'libcutils'
local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local cVector   = require 'libvctr'
local Scalar    = require 'libsclr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local tmpl      = "OPERATORS/S_TO_F/lua/rand.tmpl"
local qc        = require 'Q/UTILS/lua/q_core'

-- cdef the necessary struct within pcall to prevent error on second call
local incs = { "UTILS/inc/" }
qc.q_cdef("UTILS/inc/drand_struct.h")
qc.q_cdef("OPERATORS/S_TO_F/inc/rand_struct.h", incs)
qc.q_cdef("RUNTIME/SCLR/inc/scalar_struct.h", incs)
return function (
  in_args
  )
  --=================================
  assert(type(in_args) == "table")
  local qtype = assert(in_args.qtype)
  local len   = assert(in_args.len)
  assert(is_in(qtype, { "B1", "I1", "I2", "I4", "I8", "F4", "F8"}))
  assert(len > 0, "vector length must be positive")
  --=======================
  local subs = {}
  subs.fn = "rand_" .. qtype
  subs.len = len
  subs.out_ctype = qconsts.qtypes[qtype].ctype
  subs.out_qtype = qtype
  subs.tmpl = tmpl
  subs.buf_size = cVector.chunk_size() * qconsts.qtypes[qtype].width
  --=======================
  -- set up args for C code
  local args_ctype = "RAND_" .. qtype .. "_REC_TYPE";
  local sz = ffi.sizeof(args_ctype)
  local cargs = cmem.new({size = sz}); 
  local args = get_ptr(cargs, args_ctype .. " *")

  -- set seed
  local seed
  if ( in_args.seed ) then 
    seed = in_args.seed
    print("seed = ", seed)
  else
    seed = cutils.rdtsc() 
    -- following is to make sure we stay as integer and not fp
    seed = math.floor(seed)
    seed = seed % (4096*1048576-1)
  end
  assert(type(seed) == "number")
  assert(seed > 0)
  --=============
  local sseed = Scalar.new(seed, "I8")
  local sseed = ffi.cast("SCLR_REC_TYPE *", sseed)
  args[0]["seed"] = sseed[0].cdata["valI8"]

  subs.args       = args
  subs.args_ctype = args_ctype
  --=========================
  --=== handle B1 as special case
  if ( qtype ~= "B1" ) then
    -- set lb
    local lb   = assert(in_args.lb)
    local slb = assert(to_scalar(lb, qtype))
    local slb = ffi.cast("SCLR_REC_TYPE *", slb)
    args[0]["lb"] = slb[0].cdata["val" .. qtype]
    -- set ub
    local ub   = assert(in_args.ub)
    local sub = assert(to_scalar(ub, qtype))
    local sub = ffi.cast("SCLR_REC_TYPE *", sub)
    args[0]["ub"] = sub[0].cdata["val" .. qtype]
  
    assert(ub > lb)
    -- Check  lb, ub in range for type dony b to_scalar()
  else
    -- set probability
    local probability   = assert(in_args.probability)
    local sprobability = assert(to_scalar(probability, "F8"))
    local sprobability = ffi.cast("SCLR_REC_TYPE *", sprobability)
    args[0]["probability"] = sprobability[0].cdata["valF8"]
    subs.buf_size = cVector.chunk_size() / 8
    subs.tmpl = nil -- this is not generated code 
    subs.out_ctype = "uint64_t" 
    subs.dotc = "OPERATORS/S_TO_F/src/rand_B1.c"
    subs.doth = "OPERATORS/S_TO_F/inc/rand_B1.h"
    subs.srcs = { "UTILS/src/rdtsc.c" }
  end
  subs.incdir = "OPERATORS/S_TO_F/gen_inc/"
  subs.srcdir = "OPERATORS/S_TO_F/gen_src/"
  subs.incs = { "UTILS/inc", "OPERATORS/S_TO_F/inc/", "OPERATORS/S_TO_F/gen_inc/", }
  subs.structs = { "OPERATORS/S_TO_F/inc/rand_struct.h" }
  subs.cst_out_as = subs.out_ctype .. " * "
  return subs
end
