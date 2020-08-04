local qconsts   = require 'Q/UTILS/lua/q_consts'
local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local Scalar    = require 'libsclr'
local lVector   = require 'Q/RUNTIME/VCTR/lua/lVector'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local rev_lkp   = require 'Q/UTILS/lua/rev_lkp'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local good_qtypes = rev_lkp({ "I1", "I2", "I4", "I8", "F4", "F8"})
local qc        = require 'Q/UTILS/lua/q_core'

qc.q_cdef("OPERATORS/F_TO_S/inc/minmax_struct.h", { "UTILS/inc/" })
qc.q_cdef("RUNTIME/SCLR/inc/scalar_struct.h", { "UTILS/inc/" })

return function (operator, x, optargs)
  assert(type(operator) == "string")
  assert(type(x) == "lVector")
  assert(not x:has_nulls())
  local qtype = x:qtype()
  assert(good_qtypes[qtype])
  --====================
  local subs = {}
  subs.fn        = operator ..  "_" .. qtype 
  subs.ctype     = qconsts.qtypes[qtype].ctype
  subs.cst_in_as = subs.ctype .. " *"
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
  --=====================================
  -- set up args for C code
  subs.cargs_ctype = "MINMAX_" .. qtype .. "_ARGS";
  subs.cargs = cmem.new({size = ffi.sizeof(subs.cargs_ctype)})
  subs.cargs:zero()
  subs.cst_cargs_as = subs.cargs_ctype .. " *"
  --==========
  local getter = function (x)
    assert(type(x) == "CMEM") -- this contains the value into which reduction happens
    x = get_ptr(x, subs.cst_cargs_as)

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
  subs.incs = { "UTILS/inc", "OPERATORS/F_TO_S/inc/", "OPERATORS/F_TO_S/gen_inc/", }
  subs.structs = { "OPERATORS/F_TO_S/inc/minmax_struct.h",
                   "RUNTIME/SCLR/inc/scalar_struct.h" }
  return subs
end
