local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local Scalar  = require 'libsclr'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local is_in         = require 'Q/UTILS/lua/is_in'
local to_scalar     = require 'Q/UTILS/lua/to_scalar'

local function count_specialize(x, y)
  local subs = {}
  assert(type(x) == "lVector")
  local qtypes = { 
    "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8",  "F4", "F8", }
  
  assert(type(y) == "lVector")
  assert(x:qtype() == y:qtype())
  assert(is_in(x:qtype(), qtypes))
  if ( y:is_eov() == false ) then y:eval() end 
  subs.bin_bounds = y:num_elements()
  subs.bin_counts = y:num_elements() + 1 
  --================================================
  -- TODO P2 Check that y is sorted ascending and unique


  subs.qtype = x:qtype()
  assert(x:has_nulls() == false) -- can be relaxed later 

  subs.fn = "bin_count_" .. subs.qtype 
  subs.ctype = cutils.str_qtype_to_str_ctype(subs.qtype)
  subs.cast_in_as = subs.ctype .. " *"

  subs.tmpl   = "OPERATORS/BIN_COUNT/lua/bin_count.tmpl"
  subs.incdir = "OPERATORS/BIN_COUNT/gen_inc/"
  subs.srcdir = "OPERATORS/BIN_COUNT/gen_src/"
  subs.incs = { "UTILS/inc/", "OPERATORS/BIN_COUNT/gen_inc/" }

  --==============================
  local bin_count = cmem.new({
    size = subs.bin_counts * ffi.sizeof("int64_t"), qtype = "I8"})
  bin_count:zero()
  bin_count:stealable(true)
  subs.bin_count = bin_count
  --==============================
  subs.getter = function (x) 
    return nil -- TODO P0 a vector containing bin_count 
  end
  subs.destructor = function (x) 
    bin_count:delete()
  end
  return subs
end
return count_specialize
