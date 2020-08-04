local qconsts = require 'Q/UTILS/lua/q_consts'
local cVector = require 'libvctr'
local cutils  = require 'libcutils'
local plpath  = require 'pl.path'
local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local chunk_size = cVector.chunk_size()

local function expander_f1f2opf3(a, f1 , f2, optargs )
  local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  if ( optargs ) then 
    assert(type(optargs) == "table") 
  else
    optargs = {}
  end
  optargs.__operator = a -- needed for some specializers
  local subs = assert(spfn(f1, f2, optargs))
  -- subs should return 
  -- (1) f3_qtype (2) f1_cst_as (2) f2_cst_as (3) f3_cst_as
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  local f3_width = qconsts.qtypes[subs.f3_qtype].width
  local buf_sz = chunk_size * f3_width
  local buf = assert(cmem.new(0)) -- note we don't really allocate data

  local first_call = true
  local l_chunk_num = 0
  local f3_gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    --=== START: buffer allocation
    if ( not buf:is_data() ) then 
      buf = assert(cmem.new({size = buf_sz, qtype = subs.f3_qtype}))
      buf:stealable(true)
    end
    --=== STOP : buffer allocation
    --=============================
    local f1_len, f1_chunk, nn_f1_chunk
    local f2_len, f2_chunk, nn_f2_chunk
    f1_len, f1_chunk, nn_f1_chunk = f1:get_chunk(l_chunk_num)
    f2_len, f2_chunk, nn_f2_chunk = f2:get_chunk(l_chunk_num)
    assert(f1_len == f2_len)
    if f1_len > 0 then
      local chunk1 = get_ptr(f1_chunk, subs.f1_cast_as)
      local chunk2 = get_ptr(f2_chunk, subs.f2_cast_as)
      local chunk3 = get_ptr(buf,      subs.f3_cast_as)
      local start_time = cutils.rdtsc()
      qc[func_name](chunk1, chunk2, f1_len, chunk3)
      record_time(start_time, func_name)
    end
    f1:unget_chunk(l_chunk_num)
    f2:unget_chunk(l_chunk_num)
    if ( f1_len < chunk_size ) then 
      -- We have no use for f1, f2. Kill will delete if killable
      f1:kill() 
      f2:kill()
    end
    l_chunk_num = l_chunk_num + 1
    return f1_len, buf
  end
  return lVector{gen=f3_gen, qtype=subs.f3_qtype, has_nulls=false}
end
return expander_f1f2opf3
