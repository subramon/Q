local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local cutils    = require 'libcutils'
local is_in     = require 'RSUTILS/lua/is_in'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local qc        = require 'Q/UTILS/lua/qcore'
local qcfg      = require 'Q/UTILS/lua/qcfg'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'
local is_int_qtype = require 'Q/UTILS/lua/is_int_qtype'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

-- cdef the necessary struct within pcall to prevent error on second call

qc.q_cdef("OPERATORS/S_TO_F/inc/seq_struct.h")
return function (
  largs
  )
  --====================================
  assert(type(largs) == "table")
  local start = assert(largs.start)
  local qtype = assert(largs.qtype)
  local len   = assert(largs.len)
  local by    = assert(largs.by)
  assert(is_base_qtype(qtype)) -- at one time I had restricted this to int
  assert(len > 0, "vector length must be positive")

  local subs = {};
  --========================
  subs.fn	    = "seq_" .. qtype
  subs.len	    = len
  subs.out_qtype    = qtype
  subs.out_ctype    = cutils.str_qtype_to_str_ctype(qtype)
  subs.max_num_in_chunk = get_max_num_in_chunk (largs)
  subs.buf_size     = subs.max_num_in_chunk * cutils.get_width_qtype(qtype)
  subs.cast_buf_as  = subs.out_ctype .. " * "
  --========================
  -- set up args for C code
  local sstart = assert(to_scalar(start, qtype))
  local sby    = assert(to_scalar(by, qtype))

  -- allocate cargslocal 
  subs.cargs_ctype = "SEQ_" .. qtype .. "_REC_TYPE";
  local sz = ffi.sizeof(subs.cargs_ctype)
  subs.cargs = cmem.new(sz)
  subs.cargs:zero()
  subs.cast_cargs_as = subs.cargs_ctype .. " *"

  -- initialize cargs from scalar values 
  local cargs = get_ptr(subs.cargs, subs.cast_cargs_as)

  sstart = ffi.cast("SCLR_REC_TYPE *", sstart)
  sby    = ffi.cast("SCLR_REC_TYPE *", sby)

  cargs[0]["start"] = sstart[0].val[string.lower(qtype)]
  cargs[0]["by"]    =    sby[0].val[string.lower(qtype)]

  subs.tmpl   = "OPERATORS/S_TO_F/lua/seq.tmpl"
  subs.incdir = "OPERATORS/S_TO_F/gen_inc/"
  subs.srcdir = "OPERATORS/S_TO_F/gen_src/"
  subs.incs   = {  "OPERATORS/S_TO_F/inc/", "OPERATORS/S_TO_F/gen_inc/", }
  subs.structs = { "OPERATORS/S_TO_F/inc/seq_struct.h" }
  return subs
end
