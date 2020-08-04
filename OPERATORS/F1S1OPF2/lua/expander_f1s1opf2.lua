local qconsts  = require 'Q/UTILS/lua/q_consts'
local ffi      = require 'ffi' 
local cVector  = require 'libvctr' 
local cutils   = require 'libcutils' 
local qc       = require 'Q/UTILS/lua/q_core'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local cmem     = require 'libcmem'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local record_time = require 'Q/UTILS/lua/record_time'
local is_in    = require 'Q/UTILS/lua/is_in'

local no_scalar_ops = { "vnot", "incr", "decr", "exp", "log", "sqrt" }
local chunk_size = cVector.chunk_size()

local function expander_f1s1opf2(a, f1, sclrs, optargs )
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(f1, sclrs, optargs))

  local func_name = assert(subs.fn)
  qc.q_add(subs); 
  local cst_cargs = ffi.NULL
  local cargs = subs.cargs
  if ( cargs ) then 
    cst_cargs = assert(get_ptr(cargs, subs.cst_cargs_as))
  end

  local f2_buf    = cmem.new(0)
  local l_chunk_num = 0
  --============================================
  local f2_gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    if ( not f2_buf:is_data() ) then 
      f2_buf = assert(cmem.new( 
        { size = subs.f2_buf_sz, qtype = subs.f2_qtype}))
      f2_buf:stealable(true)
    end
    local f1_len, f1_chunk, _ = f1:get_chunk(l_chunk_num)
    if ( f1_len == 0 ) then 
      if ( cargs ) then cargs:delete() end return 0 
    end 
    local cst_f1_chunk    = get_ptr(f1_chunk, subs.cst_f1_as)
    local cst_f2_buf      = get_ptr(f2_buf,   subs.cst_f2_as)
    local start_time = cutils.rdtsc()
    local status = qc[func_name](cst_f1_chunk, f1_len, cst_cargs, cst_f2_buf)
    assert(status == 0)
    f1:unget_chunk(l_chunk_num)
    record_time(start_time, func_name)
    l_chunk_num = l_chunk_num + 1
    if ( f1_len < chunk_size ) then 
      if ( cargs ) then cargs:delete() end 
    end
    return f1_len, f2_buf
  end
  return lVector{gen = f2_gen, has_nulls = false, qtype = subs.f2_qtype}
end 
return expander_f1s1opf2
