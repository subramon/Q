local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local Scalar    = require 'libsclr'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local rev_lkp   = require 'Q/UTILS/lua/rev_lkp'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local good_qtypes = rev_lkp({ "I1", "I2", "I4", "I8", "F4", "F8"})
local for_cdef  = require 'Q/UTILS/build/for_cdef'
local qc        = require 'Q/UTILS/lua/q_core'

-- cdef the necessary struct within pcall to prevent error on second call
local incs = { "UTILS/inc/" }
qc.q_cdef("OPERATORS/F_TO_S/inc/minmax_struct.h", incs)
-- qc.q_cdef("RUNTIME/SCLR/inc/scalar_struct.h", incs)

return function (in_qtype, operator)
  assert(type(operator) == "string")
  assert(type(in_qtype) == "string")
  assert(good_qtypes[in_qtype])
  --====================
  local subs = {}
  subs.fn = operator ..  "_" .. in_qtype 
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.reduce_qtype = in_qtype
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
  --=====================================
  -- set up args for C code
  subs.args_ctype = "MINMAX_" .. in_qtype .. "_ARGS";
  local args = cmem.new({size = ffi.sizeof(subs.args_ctype)})
  args:zero()
  subs.args = get_ptr(args, subs.args_ctype .. " *")
  --==========
  local getter = function (x)
    assert(x) -- this contains the value into which reduction happens

    local sval = Scalar.new(0, subs.reduce_qtype) -- out_qtype from closure
    local s = ffi.cast("SCLR_REC_TYPE *", sval)
    local key = "val" .. subs.reduce_qtype
    s[0].cdata[key] = x[0].val
    -------------------
    local snum = Scalar.new(0, "I8")
    local s = ffi.cast("SCLR_REC_TYPE *", snum)
    local key = "valI8"
    s[0].cdata[key] = x[0].num
    -------------------
    local sidx = Scalar.new(0, "I8")
    local s = ffi.cast("SCLR_REC_TYPE *", sidx)
    local key = "valI8"
    s[0].cdata[key] = x[0].idx
    -------------------
    return sval, snum, sidx
  end
  subs.getter = getter
  subs.srcdir = "OPERATORS/F_TO_S/gen_src/"
  subs.incdir = "OPERATORS/F_TO_S/gen_inc/"
  subs.tmpl   = "OPERATORS/F_TO_S/lua/minmax.tmpl"
  return subs
end
