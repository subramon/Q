local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local cutils    = require 'libcutils'
local Scalar    = require 'libsclr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_in     = require 'RSUTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local qc        = require 'Q/UTILS/lua/qcore'
local qcfg      = require 'Q/UTILS/lua/qcfg'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'

-- cdef the necessary struct within pcall to prevent error on second call
local incs = { "RUNTIME/CMEM/inc/", "UTILS/inc/" }
qc.q_cdef("OPERATORS/S_TO_F/inc/period_struct.h", incs)
qc.q_cdef("RUNTIME/SCLR/inc/sclr_struct.h", incs)
return function (
  largs
  )
  --====================================
  assert(type(largs) == "table")
  local qtype = assert(largs.qtype)
  local len   = assert(largs.len)
  local start = assert(largs.start)
  local by    = assert(largs.by)
  local period= assert(largs.period)
  assert(is_in(qtype, { "I1", "I2", "I4", "I8", } ))
  -- "F4", "F8" not supported TODO for period P4
  assert(len > 0, "vector length must be positive")
  assert(period > 0, "period must be positive")

  local subs = {};
  --========================
  subs.fn	 = "period_" .. qtype
  subs.len	 = len
  subs.out_qtype = qtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(qtype)
  subs.max_num_in_chunk = get_max_num_in_chunk (largs)
  subs.buf_size = subs.max_num_in_chunk * cutils.get_width_qtype(qtype)
  --========================
  -- set up args for C code
  local sstart = assert(to_scalar(start, qtype))
  sstart = ffi.cast("SCLR_REC_TYPE *", sstart)
  local sby    = assert(to_scalar(by, qtype))
  sby    = ffi.cast("SCLR_REC_TYPE *", sby)
  local speriod    = assert(to_scalar(period, "I4"))
  speriod    = ffi.cast("SCLR_REC_TYPE *", speriod)

  subs.cargs_ctype = "PERIOD_" .. qtype .. "_REC_TYPE";
  local sz = ffi.sizeof(subs.cargs_ctype)
  subs.cargs = cmem.new(sz)
  subs.cast_cargs_as = subs.cargs_ctype .. " *"

  -- set cargs from scalar values 
  local cargs = assert(get_ptr(subs.cargs, subs.cast_cargs_as))
  cargs[0]["start"]  =  sstart[0].val[string.lower(qtype)]
  cargs[0]["by"]     =     sby[0].val[string.lower(qtype)]
  cargs[0]["period"] = speriod[0].val[string.lower(qtype)]

  subs.tmpl  = "OPERATORS/S_TO_F/lua/period.tmpl"
  subs.incdir = "OPERATORS/S_TO_F/gen_inc/"
  subs.srcdir = "OPERATORS/S_TO_F/gen_src/"
  subs.incs   = { "UTILS/inc", "OPERATORS/S_TO_F/inc/", "OPERATORS/S_TO_F/gen_inc/", }
  subs.structs = { "OPERATORS/S_TO_F/inc/const_struct.h" }
  subs.cast_buf_as = subs.out_ctype .. " * "
  return subs
end
