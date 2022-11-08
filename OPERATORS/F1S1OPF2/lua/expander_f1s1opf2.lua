local ffi      = require 'ffi' 
local cutils   = require 'libcutils' 
local qc       = require 'Q/UTILS/lua/qcore'
local qconsts  = require 'Q/UTILS/lua/qconsts'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local cmem     = require 'libcmem'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local record_time = require 'Q/UTILS/lua/record_time'
local is_in    = require 'Q/UTILS/lua/is_in'
local qmem    = require 'Q/UTILS/lua/qmem'
local chunk_size = qmem.chunk_size

local no_scalar_ops = { "vnot", "incr", "decr", "exp", "log", "sqrt" }

local function expander_f1s1opf2(a, f1, sclr, optargs )
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  optargs = optargs or {}
  optargs.__operator = a -- for use in specializer if needed
  local subs = assert(spfn(f1, sclr, optargs))

  local func_name = assert(subs.fn)
  qc.q_add(subs); 
  local f2_buf_sz = subs.f2_width * chunk_size

  local f2_buf    = cmem.new(0)
  local l_chunk_num = 0
  --============================================
  local f2_gen = function(chunk_num)
    error("XXX")
    assert(chunk_num == l_chunk_num)
    if ( not f2_buf:is_data() ) then 
      f2_buf = assert(cmem.new( 
        { size = f2_buf_sz, qtype = subs.f2_qtype}))
      f2_buf:stealable(true)
    end
    local f1_len, f1_chunk, _ = f1:get_chunk(l_chunk_num)
    if ( f1_len == 0 ) then 
      if ( cargs ) then cargs:delete() end return 0 
    end 
    local cst_f1_chunk    = get_ptr(f1_chunk, subs.cst_f1_as)
    local cst_f2_buf      = get_ptr(f2_buf,   subs.cst_f2_as)
    local start_time = cutils.rdtsc()
    local status = qc[func_name](cst_f1_chunk, f1_len, subs.cst_cargs, 
      cst_f2_buf)
    assert(status == 0)
    print("VVVV", f1:name(), f1:num_readers())
    f1:unget_chunk(l_chunk_num)
    print("XXXX", f1:name(), f1:num_readers())
    record_time(start_time, func_name)
    l_chunk_num = l_chunk_num + 1
    if ( f1_len < chunk_size ) then 
      if ( ( subs.cargs ) and ( type(subs.cargs) == "CMEM" ) ) then 
        cargs:delete() 
      end 
    end
    return f1_len, f2_buf
  end
  return lVector{gen = f2_gen, has_nulls = false, qtype = subs.f2_qtype}
end 
return expander_f1s1opf2
