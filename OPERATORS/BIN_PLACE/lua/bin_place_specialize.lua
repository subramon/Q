local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local cutils    = require 'libcutils'
local Scalar    = require 'libsclr'
local lVector   = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local is_in     = require 'Q/UTILS/lua/is_in'
local to_scalar = require 'Q/UTILS/lua/to_scalar'

local function bin_place_specialize(x, lb, ub, cnt, optargs)
  local subs = {}
  assert(type(x) == "lVector")
  assert(x:has_nulls() == false)
  -- x does not have to be eov 
  local qtypes = { 
    "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8",  "F4", "F8", }
  subs.qtype = x:qtype()
  assert(is_in(subs.qtype, qtypes))

  subs.drop_mem = false
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if (type(optargs.drop_mem) ~= "nil") then 
      assert(type(optargs.drop_mem) == "boolean")
      subs.drop_mem = optargs.drop_mem
    end
  end

  assert(type(lb) == "lVector")
  assert(lb:qtype() == subs.qtype)
  assert(lb:has_nulls() == false)
  assert(lb:is_eov())
  assert(lb:chunks_to_lma())

  assert(type(ub) == "lVector")
  assert(ub:qtype() == subs.qtype)
  assert(ub:has_nulls() == false)
  assert(ub:is_eov())
  assert(ub:chunks_to_lma())

  assert(type(cnt) == "lVector")
  assert(cnt:qtype() == "I8")
  assert(cnt:has_nulls() == false)
  assert(cnt:is_eov())
  assert(cnt:chunks_to_lma())

  assert(lb:num_elements() == ub:num_elements())
  assert(ub:num_elements() == cnt:num_elements())

  subs.ctype = cutils.str_qtype_to_str_ctype(subs.qtype)
  subs.cast_in_as = subs.ctype .. " *"
  subs.cast_lb_as = subs.ctype .. " *"
  subs.cast_ub_as = subs.ctype .. " *"
  subs.cast_cnt_as = "uint64_t *"
  subs.cast_off_as = "uint64_t *"
  subs.cast_lck_as = "int32_t *"

  -- START: make offsets
  -- get access to cnt 
  local cntcmem, nn_cntcmem, ncnt = cnt:get_lma_read()
  local cntptr = get_ptr(cntcmem, subs.cast_cnt_as)
  -- ==================
  local n = cnt:num_elements()
  local sz = ffi.sizeof("uint64_t") * n
  subs.off_cmem = cmem.new({qtype = "UI8", size = sz})
  subs.off = get_ptr(subs.off_cmem, "UI8")
  subs.off[0] = 0
  for i = 1, n-1 do 
    subs.off[i] = cntptr[i-1] + subs.off[i-1]
  end
  cnt:unget_lma_read()
  -- STOP : make offsets
  -- START: make locks
  -- subs.lck_cmem = cmem.new({qtype = "I4", size = sz})
  -- subs.lck_cmem:zero()
  -- STOP : make locks

  subs.fn = "bin_place_" .. subs.qtype 
  subs.tmpl   = "OPERATORS/BIN_PLACE/lua/bin_place.tmpl"
  subs.incdir = "OPERATORS/BIN_PLACE/gen_inc/"
  subs.srcdir = "OPERATORS/BIN_PLACE/gen_src/"
  subs.incs = { "UTILS/inc/", "OPERATORS/BIN_PLACE/gen_inc/" }

  return subs
end
return bin_place_specialize
