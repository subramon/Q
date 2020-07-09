local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local Scalar    = require 'libsclr'
local cVector   = require 'libvctr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local tmpl      = "OPERATORS/S_TO_F/lua/const.tmpl"
local qc        = require 'Q/UTILS/lua/q_core'

-- cdef the necessary struct within pcall to prevent error on second call
local incs = { "UTILS/inc/" }
qc.q_cdef("OPERATORS/S_TO_F/inc/const_struct.h", incs)
qc.q_cdef("RUNTIME/SCLR/inc/scalar_struct.h", incs)

return function (
  in_args
  )

  assert(type(in_args) == "table")
  local qtype = assert(in_args.qtype)
  local len   = assert(in_args.len)
  assert(is_in(qtype, { "B1", "I1", "I2", "I4", "I8", "F4", "F8"}))
  assert(len > 0, "vector length must be positive")
  --=======================
  local subs = {};
  subs.fn = "const_" .. qtype
  subs.len = len
  subs.out_ctype = qconsts.qtypes[qtype].ctype
  subs.out_qtype = qtype
  subs.tmpl = tmpl
  subs.buf_size = cVector.chunk_size() * qconsts.qtypes[qtype].width

  -- set up args for C code
  local val  = in_args.val
  assert(type(val) ~= nil)
  local sval = assert(to_scalar(val, qtype))
  local args_ctype = "CONST_" .. qtype .. "_REC_TYPE";
  local sz = ffi.sizeof(args_ctype)
  local cargs = cmem.new({size = sz}); 
  local args = get_ptr(cargs, args_ctype .. " *")

  local s = ffi.cast("SCLR_REC_TYPE *", sval)
  args[0]["val"] = s[0].cdata["val" .. qtype]

  subs.args       = args
  subs.args_ctype = args_ctype
  --=== handle B1 as special case
  if ( qtype == "B1" ) then
    subs.buf_size = cVector.chunk_size() / 8
    subs.tmpl = nil -- this is not generated code 
    subs.out_ctype = "uint64_t" 
    subs.dotc   = "OPERATORS/S_TO_F/src/const_B1.c"
    subs.doth   = "OPERATORS/S_TO_F/inc/const_B1.h"
    subs.incdir = "OPERATORS/S_TO_F/inc/"
    subs.srcdir = "OPERATORS/S_TO_F/src/"
  end
  subs.incdir = "OPERATORS/S_TO_F/gen_inc/"
  subs.srcdir = "OPERATORS/S_TO_F/gen_src/"
  return subs
end

