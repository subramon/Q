local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local promote = require 'Q/UTILS/lua/promote'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qc      = require 'Q/UTILS/lua/qcore'
local is_in   = require 'Q/UTILS/lua/is_in'
local qcfg    = require 'Q/UTILS/lua/qcfg'

qc.q_cdef("OPERATORS/F1F2OPF3/inc/f1f2opf3_concat.h") 

local function set_defaults(f1_qtype, f2_qtype)
  local w1 = cutils.get_width_qtype(f1_qtype)
  local w2 = cutils.get_width_qtype(f2_qtype)
  assert(( w1 <= 4 ) and ( w2 <= 4 ))
  local shift_by, f3_qtype
  if ( w1 == 1 ) then
    if ( w2 == 1 ) then 
      shift_by = 8
      f3_qtype = "UI16"
    elseif ( w2 == 2 ) then 
      f3_qtype = "UI4"
      shift_by = 16
    elseif ( w2 == 4 ) then 
      f3_qtype = "UI8"
      shift_by = 32
    else 
      error("Cannot concat " ..  f1_qtype .. " and " ..  f2_qtype)
    end
  elseif ( w1 == 2 ) then 
    if ( w2 == 1 ) then 
      f3_qtype = U"I4"
      shift_by = 8
    elseif ( w2 == 2 ) then 
      f3_qtype = "UI4"
      shift_by = 16
    elseif ( w2 == 4 ) then 
      f3_qtype = "UI8"
      shift_by = 32
    else 
      error("Cannot concat " ..  f1_qtype .. " and " ..  f2_qtype)
    end
  elseif ( w1 == 4 ) then 
    f3_qtype = "UI8"
    if ( w2 == 1 ) then 
      shift_by = 8
    elseif ( w2 == 2 ) then
      shift_by = 16
    elseif ( w2 == 4 ) then 
      shift_by = 32
    else 
      error("Cannot concat " ..  f1_qtype .. " and " ..  f2_qtype)
    end
  end
  return f3_qtype, shift_by
end



return function (
  op,
  f1, 
  f2,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); 
  assert(not f1:has_nulls())
  assert(type(f2) == "lVector"); 
  assert(not f2:has_nulls())
  local f1_qtype = f1:qtype();   
  assert(is_in(f1_qtype, 
    { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", }))
  local f2_qtype = f2:qtype();   
  assert(is_in(f2_qtype, 
    { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", }))
  assert(f1:max_num_in_chunk() == f2:max_num_in_chunk())
  subs.max_num_in_chunk = f1:max_num_in_chunk()

  local f3_qtype, shift_by = set_defaults(f1_qtype, f2_qtype)
  assert(type(f3_qtype) == "string")
  assert(type(shift_by) == "number")
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.f3_qtype ) then 
      f3_qtype = optargs.f3_qtype
    end
    if ( optargs.shift_by ) then 
      shift_by = optargs.shift_by
    end
  end
  assert(is_in(f3_qtype, { "I2", "I4", "I8", "UI2", "UI4", "UI8", }))
  assert( (shift_by >= 0 )  and ( shift_by < 63 ))
  
  subs.fn = op .. "_" .. f1_qtype .. "_" .. f2_qtype .. "_" .. f3_qtype 
  subs.fn_ispc = subs.fn .. "_ispc"
  if ( is_in(f1_qtype, { "I1", "I2", "I4", "I8", }) ) then 
    subs.f1_ctype = "u" .. cutils.str_qtype_to_str_ctype(f1_qtype)
  else
    subs.f1_ctype = cutils.str_qtype_to_str_ctype(f1_qtype)
  end
  if ( is_in(f2_qtype, { "I1", "I2", "I4", "I8", }) ) then 
    subs.f2_ctype = "u" .. cutils.str_qtype_to_str_ctype(f2_qtype)
  else
    subs.f2_ctype = cutils.str_qtype_to_str_ctype(f2_qtype)
  end
  subs.f3_qtype = f3_qtype
  if ( is_in(f3_qtype, { "I1", "I2", "I4", "I8", }) ) then 
    subs.f3_ctype = "u" .. cutils.str_qtype_to_str_ctype(f3_qtype)
  else
    subs.f3_ctype = cutils.str_qtype_to_str_ctype(f3_qtype)
  end

  subs.f3_width = cutils.get_width_qtype(subs.f3_qtype)
  subs.bufsz  = subs.f3_width * subs.max_num_in_chunk

  -- allocate cargs
  local sz = ffi.sizeof("f1f2opf3_concat_t")
  subs.cargs = assert(cmem.new(sz))
  subs.cargs:zero()
  -- initialize cargs from scalar values 
  local cst_cargs = get_ptr(subs.cargs, "f1f2opf3_concat_t *")
  cst_cargs[0]["shift_by"] = shift_by
  subs.cst_cargs = cst_cargs

  subs.chunk_size = 1024 -- TODO P4 experiment 

  subs.f1_cast_as = subs.f1_ctype .. "*"
  subs.f2_cast_as = subs.f2_ctype .. "*"
  subs.f3_cast_as = subs.f3_ctype .. "*"

  subs.tmpl   = "OPERATORS/F1F2OPF3/lua/concat.tmpl"
  subs.incdir = "OPERATORS/F1F2OPF3/gen_inc/"
  subs.srcdir = "OPERATORS/F1F2OPF3/gen_src/"
  subs.incs = { "OPERATORS/F1F2OPF3/gen_inc/", "UTILS/inc/", 
    "OPERATORS/F1F2OPF3/inc/" }

  subs.libs = { "-lgomp", "-lm" } 
  if ( qcfg.use_ispc ) then 
    subs.f1_ctype_ispc = "u" .. cutils.str_qtype_to_str_ispctype(f1_qtype)
    subs.f2_ctype_ispc = "u" .. cutils.str_qtype_to_str_ispctype(f2_qtype)
    subs.f3_ctype_ispc = "u" .. cutils.str_qtype_to_str_ispctype(f3_qtype)
    subs.tmpl_ispc   = "OPERATORS/F1F2OPF3/lua/concat_ispc.tmpl"
    subs.ispc_comment = ""
  else
    subs.ispc_comment = "//"
  end
  return subs
end
