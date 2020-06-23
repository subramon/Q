local Scalar    = require 'libsclr'
local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local tmpl      = qconsts.Q_SRC_ROOT .. "/ML/DT/lua/dt_benefit.tmpl"
local valid_f_types = { "I1", "I2", "I4", "I8", "F4", "F8" }
local valid_g_types = { "I4" } 
return function (
  f_qtype,
  g_qtype,
  metric_name,
  min_size,
  wt_prior,
  n_T,
  n_H
  )
  local subs = {}; 
  assert(type(min_size) == "number")
  assert(type(wt_prior) == "number")
  assert(type(n_T) == "number")
  assert(type(n_H) == "number")

  assert(min_size > 1)
  assert(n_T > 0)
  assert(n_H > 0)
  assert(n_T+n_H > min_size)
  assert(wt_prior >= 0)

  -- TODO P3 Need to keep this in sync with ../inc/dt_benefit_struct.h
  local hdr = [[
typedef struct _dt_benefit_args {
  double   val; // best split point 
  uint64_t num; // number of values consumed so far
  uint64_t n_L_T; // initialized to 0, increments later on
  uint64_t n_L_H; // initialized to 0, increments later on
  uint64_t n_T; // set before first call 
  uint64_t n_H; // set before first call 
  uint64_t min_size; // set in specializer
  double benefit; // initialized to 0, increments later on
} DT_BENEFIT_ARGS;
]]
  pcall(ffi.cdef, hdr)

  -- TODO P4 When you have different metrics, you need to
  -- set subs.fn accordingly
  assert(is_in(f_qtype, valid_f_types))
  assert(is_in(g_qtype, valid_g_types))
  subs.fn = "dt_benefit_" .. f_qtype .. "_" .. g_qtype
  subs.f_ctype = qconsts.qtypes[f_qtype].ctype
  subs.g_ctype = qconsts.qtypes[g_qtype].ctype

  subs.c_qtype = "I4"
  subs.c_ctype = qconsts.qtypes[subs.c_qtype].ctype

  subs.v_qtype = f_qtype
  subs.v_ctype = qconsts.qtypes[subs.v_qtype].ctype

  local reduce_struct = cmem.new({size = ffi.sizeof("DT_BENEFIT_ARGS")})
  reduce_struct:zero()
  subs.reduce_struct = get_ptr(reduce_struct, "DT_BENEFIT_ARGS *")
  subs.reduce_struct_ctype = "DT_BENEFIT_ARGS"

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
