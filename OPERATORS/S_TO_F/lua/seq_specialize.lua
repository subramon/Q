local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local cVector   = require 'libvctr'
local Scalar    = require 'libsclr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local tmpl      = qconsts.Q_SRC_ROOT .. "/OPERATORS/S_TO_F/lua/seq.tmpl"

return function (
  in_args
  )
  --====================================
  assert(type(in_args) == "table")
  local start = assert(in_args.start)
  local qtype = assert(in_args.qtype)
  local len   = assert(in_args.len)
  local by    = assert(in_args.by)
  local ctype = assert(qconsts.qtypes[qtype].ctype)
  assert(is_in(qtype, { "I1", "I2", "I4", "I8", "F4", "F8"}))
  assert(len > 0, "vector length must be positive")

  local subs = {};
  --========================
  subs.fn	    = "seq_" .. qtype
  subs.len	    = len
  subs.out_qtype    = qtype
  subs.out_ctype    = qconsts.qtypes[qtype].ctype
  subs.tmpl         = tmpl
  subs.buf_size = cVector.chunk_size() * qconsts.qtypes[qtype].width
  --========================
  -- set up args for C code
  local sstart = assert(to_scalar(start, qtype))
  sstart = ffi.cast("SCLR_REC_TYPE *", sstart)
  local sby    = assert(to_scalar(by, qtype))
  sby    = ffi.cast("SCLR_REC_TYPE *", sby)

  local args_ctype = "SEQ_" .. qtype .. "_REC_TYPE";
  local sz = ffi.sizeof(args_ctype)
  local cargs = cmem.new({size = sz}); 
  local args = get_ptr(cargs, args_ctype .. " *")

  args[0]["start"] = sstart[0].cdata["val" .. qtype]
  args[0]["by"]    =    sby[0].cdata["val" .. qtype]

  subs.args       = args
  subs.args_ctype = args_ctype
  subs.incdir = "OPERATORS/S_TO_F/gen_inc/"
  subs.srcdir = "OPERATORS/S_TO_F/gen_src/"
  return subs
end
