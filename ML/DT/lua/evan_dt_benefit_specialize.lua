local Scalar    = require 'libsclr'
local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local tmpl      = qconsts.Q_SRC_ROOT .. "/ML/DT/lua/evan_dt_benefit.tmpl"
return function (
  V_qtype,
  metric_name,
  min_size,
  sum,
  cnt
  )
  local subs = {}; 
  assert(type(metric_name) == "string") -- unused right now 
  assert(type(min_size)    == "number")
  assert(type(sum)         == "number")
  assert(type(cnt)         == "number")

  assert(min_size > 1)
  assert(cnt      > 1)

  -- TODO P3 Need to keep this in sync with ../inc/evan_dt_benefit_struct.h
  local hdr = [[
typedef struct _evan_dt_benefit_args {
  double   val; // best split point: set in C code
  uint64_t num; // number of values consumed so fa: set in C code
  double total_sum; // Should be set before call 
  uint64_t total_cnt; // Should be set before call 
  double l_sum; // initialized to 0, increments later on
  uint64_t l_cnt; // initialized to 0, increments later on
  double r_sum; // initialized to total_sum, decrements later on
  uint64_t r_cnt; // initialized to total_sum, decrements later on
  uint32_t min_size; // set in specializer
  double benefit; // initialized to 0, increments later on
} EVAN_DT_BENEFIT_ARGS;
]]
  pcall(ffi.cdef, hdr)

  -- TODO P4 When you have different metrics, you need to
  -- set subs.fn accordingly
  assert(is_in(V_qtype, { "I1", "I2", "I4", "I8", "F4", "F8"}))
  subs.fn = "evan_dt_benefit_" .. V_qtype 
  subs.V_ctype = qconsts.qtypes[V_qtype].ctype
  subs.S_ctype = qconsts.qtypes["F8"].ctype
  subs.C_ctype = qconsts.qtypes["I4"].ctype

  local reduce_struct = cmem.new({size = ffi.sizeof("EVAN_DT_BENEFIT_ARGS")})
  reduce_struct:zero()
  subs.reduce_struct = get_ptr(reduce_struct, "EVAN_DT_BENEFIT_ARGS *")
  subs.reduce_struct[0].min_size = min_size
  subs.reduce_struct[0].total_sum = sum
  subs.reduce_struct[0].total_cnt = cnt
  subs.reduce_struct[0].r_sum     = sum
  subs.reduce_struct[0].r_cnt     = cnt
  subs.reduce_struct[0].benefit   = sum/cnt
  subs.reduce_struct_ctype = "EVAN_DT_BENEFIT_ARGS"

  local getter = function (x)
    assert(x) -- this contains the value into which reduction happens

    local sval = Scalar.new(0, "F8")
    local s = ffi.cast("SCLR_REC_TYPE *", sval)
    s[0].cdata.valF8 = x[0].val
    -------------------
    local sbenefit = Scalar.new(0, "F8")
    local s = ffi.cast("SCLR_REC_TYPE *", sbenefit)
    s[0].cdata.valF8 = x[0].benefit
    -------------------
    return sval, sbenefit
  end
  subs.getter = getter

  subs.tmpl = tmpl
  return subs
end
