local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local cutils    = require 'libcutils'
local Scalar    = require 'libsclr'
local lVector   = require 'Q/RUNTIME/VCTRS/lua/lVector'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local good_qtypes =  { "BL", "I1", "I2", "I4", "I8", "F4", "F8", 
  "UI1", "UI2", "UI4", "UI8", }
local qc        = require 'Q/UTILS/lua/qcore'

qc.q_cdef("OPERATORS/F_TO_S/inc/minmax_struct.h", { "UTILS/inc/" })
qc.q_cdef("RUNTIME/SCLR/inc/sclr_struct.h", { "UTILS/inc/" })

return function (operator, x, optargs)
  assert(type(operator) == "string")
  assert(type(x) == "lVector")
  assert(not x:has_nulls())
  local qtype = x:qtype()
  assert(is_in(qtype, good_qtypes))
  --====================
  local subs = {}
  subs.fn        = operator ..  "_" .. qtype 
  subs.ctype     = cutils.str_qtype_to_str_ctype(qtype)
  subs.cast_in_as = "const " .. subs.ctype .. " *"
  subs.reduce_qtype = qtype
  if ( operator == "min" ) then 
    subs.comparator     = " < "
    subs.alt_comparator = " <= "
  elseif ( operator == "max" ) then 
    subs.comparator     = " > "
    subs.alt_comparator = " >= "
  else
    error(operator)
  end
  subs.operator = operator -- used by check_subs()
  subs.max_num_in_chunk = assert(x:max_num_in_chunk())
  --=====================================
  -- set up args for C code
  subs.accumulator_ctype = "MINMAX_" .. qtype .. "_ARGS";
  subs.accumulator = cmem.new(ffi.sizeof(subs.accumulator_ctype))
  subs.accumulator:zero()
  subs.cast_accumulator_as = subs.accumulator_ctype .. " *"
  --==========
  local getter = function (x)
    -- x contains the value into which reduction happens
    assert(type(x) == "CMEM") 
    x = get_ptr(x, subs.cast_accumulator_as)

    local sval = Scalar.new(0, subs.reduce_qtype) -- out_qtype from closure
    local tmps = ffi.cast("SCLR_REC_TYPE *", sval)
    local key = string.lower(subs.reduce_qtype)
    tmps[0].val[key] = x[0].val
    -------------------
    local snum = Scalar.new(0, "I8")
    local tmps = ffi.cast("SCLR_REC_TYPE *", snum)
    tmps[0].val["i8"] = x[0].num
    -------------------
    local sidx = Scalar.new(0, "I8")
    local tmps = ffi.cast("SCLR_REC_TYPE *", sidx)
    tmps[0].val["i8"] = x[0].idx
    -------------------
    return sval, snum, sidx
  end
  subs.getter = getter
  subs.srcdir = "OPERATORS/F_TO_S/gen_src/"
  subs.incdir = "OPERATORS/F_TO_S/gen_inc/"
  subs.tmpl   = "OPERATORS/F_TO_S/lua/minmax.tmpl"
  subs.incs = { "UTILS/inc", "OPERATORS/F_TO_S/inc/", "OPERATORS/F_TO_S/gen_inc/", }
  subs.structs = { "OPERATORS/F_TO_S/inc/minmax_struct.h",
                   "RUNTIME/SCLR/inc/sclr_struct.h" }
  return subs
end
