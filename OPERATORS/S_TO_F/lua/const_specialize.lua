local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local Scalar    = require 'libsclr'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local qc        = require 'Q/UTILS/lua/qcore'
local qcfg    =  require 'Q/UTILS/lua/qcfg'
local num_in_chunk =  qcfg.num_in_chunk

-- cdef the necessary struct within pcall to prevent error on second call
local incs = { "RUNTIME/CMEM/inc/", "UTILS/inc/" }
qc.q_cdef("OPERATORS/S_TO_F/inc/const_struct.h", incs)
qc.q_cdef("RUNTIME/SCLR/inc/sclr_struct.h", incs)

local function const_specialize(
  largs
  )

  assert(type(largs) == "table")

  local qtype = assert(largs.qtype)
  assert(is_in(qtype, { "B1", "I1", "I2", "I4", "I8", "F4", "F8"}))

  local len   = assert(largs.len)
  assert(len > 0, "vector length must be positive")
  --=======================
  local subs = {};
  subs.fn = "const_" .. qtype
  subs.len = len
  subs.out_qtype = qtype
  subs.out_ctype = cutils.get_c_qtype(qtype)
  subs.buf_size = num_in_chunk * cutils.get_width_qtype(qtype)
  subs.cast_buf_as = subs.out_ctype .. " * "

  -- set up args for C code
  local val  = largs.val
  assert(type(val) ~= nil)
  local sclr_val = Scalar(val, qtype)

  -- allocate cargs 
  subs.cargs_ctype = "CONST_" .. qtype .. "_REC_TYPE";
  local sz = ffi.sizeof(subs.cargs_ctype)
  subs.cargs = cmem.new(sz)
  subs.cargs:zero()
  subs.cast_cargs_as = subs.cargs_ctype .. " *"

  -- initialize cargs from scalar sclr_val
  local cargs = assert(get_ptr(subs.cargs, subs.cast_cargs_as))
  local sclr_val = ffi.cast("SCLR_REC_TYPE *", sclr_val)
  cargs[0]["val"] = sclr_val[0].val.[string.lower(qtype)]

  subs.tmpl   = "OPERATORS/S_TO_F/lua/const.tmpl"
  subs.incdir = "OPERATORS/S_TO_F/gen_inc/"
  subs.srcdir = "OPERATORS/S_TO_F/gen_src/"
  subs.incs   = { "UTILS/inc", "OPERATORS/S_TO_F/inc/", "OPERATORS/S_TO_F/gen_inc/", }
  subs.structs = { "OPERATORS/S_TO_F/inc/const_struct.h" }
  --=== handle B1 as special case
  if ( qtype == "B1" ) then
    subs.tmpl = nil -- this is not generated code 
    subs.dotc   = "OPERATORS/S_TO_F/src/const_B1.c"
    subs.doth   = "OPERATORS/S_TO_F/inc/const_B1.h"
  end
  return subs
end
return const_specialize
