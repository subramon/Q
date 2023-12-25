local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local Scalar  = require 'libsclr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local to_scalar     = require 'Q/UTILS/lua/to_scalar'

local function count_specialize(invec, sclr)
  local subs = {}
  assert(type(invec) == "lVector")
  if ( type(sclr) == "number") then
    sclr = assert(to_scalar(sclr, invec:qtype()))
  end
  assert(type(sclr) == "Scalar")
  subs.sclr = sclr
  subs.qtype = invec:qtype()
  assert(subs.qtype == sclr:qtype()) -- TODO P4 relax
  assert(subs.qtype ~= "BL")
  assert(is_base_qtype(subs.qtype))
  assert(invec:has_nulls() == false)

  subs.fn = "count_" .. subs.qtype 
  subs.ctype = cutils.str_qtype_to_str_ctype(subs.qtype)
  subs.cast_in_as = subs.ctype .. " *"
  subs.tmpl   = "OPERATORS/COUNT/lua/count.tmpl"
  subs.incdir = "OPERATORS/COUNT/gen_inc/"
  subs.srcdir = "OPERATORS/COUNT/gen_src/"
  subs.incs = { "UTILS/inc/", "OPERATORS/COUNT/gen_inc/" }
 -- ?? subs.reduce_qtype = "I8"
 -- ?? subs.reduce_ctype = cutils.str_qtype_to_str_ctype(subs.reduce_qtype)

  --==============================
  local count = cmem.new({size = ffi.sizeof("uint64_t"), qtype = "UI8"})
  count:zero()
  subs.count = count
  --==============================
  subs.getter = function (x) 
    return Scalar.new(count, "UI8")
  end
  subs.destructor = function (x) 
    count:delete()
  end
  return subs
end
return count_specialize
