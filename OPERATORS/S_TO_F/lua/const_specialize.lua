local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local Scalar    = require 'libsclr'
local cVector   = require 'libvctr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local qc        = require 'Q/UTILS/lua/q_core'

-- cdef the necessary struct within pcall to prevent error on second call
local incs = { "UTILS/inc/" }
qc.q_cdef("OPERATORS/S_TO_F/inc/const_struct.h", incs)
qc.q_cdef("RUNTIME/SCLR/inc/scalar_struct.h", incs)

return function (
  largs
  )

  assert(type(largs) == "table")
  local qtype = assert(largs.qtype)
  local len   = assert(largs.len)
  assert(is_in(qtype, { "B1", "I1", "I2", "I4", "I8", "F4", "F8"}))
  assert(len > 0, "vector length must be positive")
  --=======================
  local subs = {};
  subs.fn = "const_" .. qtype
  subs.len = len
  subs.out_qtype = qtype
  subs.out_ctype = qconsts.qtypes[qtype].ctype
  subs.out_buf_size = cVector.chunk_size() * qconsts.qtypes[qtype].width
  subs.cst_out_as = subs.out_ctype .. " * "

  -- set up args for C code
  local val  = largs.val
  assert(type(val) ~= nil)
  local sval = assert(to_scalar(val, qtype))

  -- allocate cargs 
  subs.cargs_ctype = "CONST_" .. qtype .. "_REC_TYPE";
  local sz = ffi.sizeof(subs.cargs_ctype)
  subs.cargs = cmem.new(sz)
  subs.cargs:zero()
  subs.cst_cargs_as = subs.cargs_ctype .. " *"

  -- initialize cargs from scalar sval
  local cargs = assert(get_ptr(subs.cargs, subs.cst_cargs_as))
  local s = ffi.cast("SCLR_REC_TYPE *", sval)
  cargs[0]["val"] = s[0].cdata["val" .. qtype]

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

