local ffi      = require 'ffi'
local cmem     = require 'libcmem'
local cutils   = require 'libcutils'
local Scalar   = require 'libsclr'
local is_in    = require 'RSUTILS/lua/is_in'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local qcfg     =  require 'Q/UTILS/lua/qcfg'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'

-- cdef the necessary struct within pcall to prevent error on second call
qc.q_cdef("OPERATORS/S_TO_F/inc/const_struct.h")
qc.q_cdef("OPERATORS/S_TO_F/inc/const_B1.h")

local function const_specialize(
  largs
  )

  assert(type(largs) == "table")

  local qtype = assert(largs.qtype)
  assert(is_in(qtype, { "B1", "BL", 
    "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", "F4", "F8"}))

  local len   = assert(largs.len)
  assert(len > 0, "vector length must be positive")
  --=======================
  local subs = {};
  subs.fn = "const_" .. qtype
  subs.len = len
  subs.out_qtype = qtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  subs.cast_buf_as = subs.out_ctype .. " * "

  subs.max_num_in_chunk = get_max_num_in_chunk (largs)
  subs.buf_size = subs.max_num_in_chunk * 
    cutils.get_width_qtype(subs.out_qtype)

  -- set up args for C code
  local val  = assert(largs.val)
  local sclr_val 

  -- handle special case of B1 
  if ( qtype == "B1" ) then 
    subs.out_qtype = "B1"
    subs.out_ctype = "uint64_t"
    subs.buf_size = subs.max_num_in_chunk / 8 
    -- sclr_val not used 
  else
    -- print("CONST: Creating a scalar ", val, qtype)
    sclr_val = Scalar.new(val, qtype)
  end
  -- allocate cargs 
  subs.cargs_ctype = "CONST_" .. qtype .. "_REC_TYPE";
  local sz = ffi.sizeof(subs.cargs_ctype)
  subs.cargs = cmem.new({ size = sz, name = "const_rec"})
  subs.cargs:zero()
  subs.cast_cargs_as = subs.cargs_ctype .. " *"

  -- initialize cargs from scalar sclr_val
  local cargs = assert(get_ptr(subs.cargs, subs.cast_cargs_as))
  local sclr_val = ffi.cast("SCLR_REC_TYPE *", sclr_val)
  -- handle special case of B1 
  if ( qtype == "B1" ) then 
    if ( val == false ) then 
      cargs[0]["val"] = 0;
    elseif ( val == true ) then 
      cargs[0]["val"] = 1;
    else
      error("bad value for B1")
    end
  else
    cargs[0]["val"] = sclr_val[0].val[string.lower(qtype)]
  end

  subs.tmpl   = "OPERATORS/S_TO_F/lua/const.tmpl"
  subs.incdir = "OPERATORS/S_TO_F/gen_inc/"
  subs.srcdir = "OPERATORS/S_TO_F/gen_src/"
  subs.incs   = { 
      "UTILS/inc", 
      "OPERATORS/S_TO_F/inc/", 
      "OPERATORS/S_TO_F/gen_inc/", }
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
