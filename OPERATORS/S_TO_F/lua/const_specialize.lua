local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local Scalar    = require 'libsclr'
local cVector   = require 'libvctr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local tmpl      = qconsts.Q_SRC_ROOT .. "/OPERATORS/S_TO_F/lua/const.tmpl"

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
  local val   = assert(in_args.val)
  local sval = assert(to_scalar(val, qtype))
  local args_ctype = "CONST_" .. qtype .. "_REC_TYPE";
  local sz = ffi.sizeof(args_ctype)
  local cargs = cmem.new(sz, qtype, qtype); 
  local args = ffi.cast(args_ctype .. " *", get_ptr(cargs))

  local s = ffi.cast("SCLR_REC_TYPE *", sval)
  local kc = val
  args[0]["val"] = s[0].cdata["val" .. qtype]

  subs.args       = args
  subs.args_ctype = args_ctype
  --=== handle B1 as special case
  if ( qtype == "B1" ) then
    subs.buf_size = cVector.chunk_size() / 8
    subs.tmpl = nil -- this is not generated code 
    subs.out_ctype = "uint64_t" 
    subs.dotc = qconsts.Q_SRC_ROOT .. "/OPERATORS/S_TO_F/src/const_B1.c"
    subs.doth = qconsts.Q_SRC_ROOT .. "/OPERATORS/S_TO_F/inc/const_B1.h"
  end
  return subs
end

