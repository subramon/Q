local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local Reducer  = require 'Q/RUNTIME/RDCR/lua/Reducer'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local cVector  = require 'libvctr'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

-- Currently, can only accept goals with 2 values
local function dt_benefit(f, gT, gH, 
  metric_name, min_size, wt_prior, n_T, n_H)
  -- f is the data vector
  -- gT is the counts when goal has value 0
  -- gH is the counts when goal has value 1
  assert(type(f) == "lVector", "f must be a lVector ")
  assert(type(gT) == "lVector", "g must be a lVector ")
  assert(type(gH) == "lVector", "g must be a lVector ")
  assert(not f:has_nulls())
  assert(not gT:has_nulls())
  assert(not gH:has_nulls())
  assert(gT:qtype() == gH:qtype())
  -- TODO P3: Check that f is sorted ascending
  --=======================
  local sp_fn_name = "Q/ML/DT/lua/dt_benefit_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, f:qtype(), gT:qtype(), 
    metric_name, min_size, wt_prior, n_T, n_H)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)
  --================================
  -- Note implicit assumption that number of elements for a specific 
  -- data value will be no more than 2^32
  --=================================
  local reduce_struct = assert(subs.reduce_struct)
  local getter = assert(subs.getter)
  assert(type(getter) == "function")
  reduce_struct[0].min_size = min_size
  reduce_struct[0].wt_prior = wt_prior
  reduce_struct[0].n_T = n_T;
  reduce_struct[0].n_H = n_H;
  local cst_f_as = subs.f_ctype .. " * "
  local cst_g_as = subs.g_ctype .. " * "
  --=================================
  local chunk_size = cVector.chunk_size()
  local l_chunk_num = 0

  local function lgen(chunk_num)
    local is_eor = false
    assert(chunk_num == l_chunk_num)
    local f_len, f_chunk = f:get_chunk(l_chunk_num)
    local gT_len, gT_chunk = gT:get_chunk(l_chunk_num)
    local gH_len, gH_chunk = gH:get_chunk(l_chunk_num)
    assert(f_len == gT_len) -- vectors need to be same size 
    assert(gT_len == gH_len) -- vectors need to be same size 
    if ( f_len == 0 ) then -- no more input, return whatever is in out
      return reduce_struct, true 
    end
    local cst_f_chunk  = ffi.cast(cst_f_as,   get_ptr(f_chunk))
    local cst_gT_chunk = ffi.cast(cst_g_as,   get_ptr(gT_chunk))
    local cst_gH_chunk = ffi.cast(cst_g_as,   get_ptr(gH_chunk))
    local start_time = qc.RDTSC()
    local status = qc[func_name](cst_f_chunk, cst_gT_chunk, cst_gH_chunk, 
        f_len, min_size, wt_prior, reduce_struct)
    assert(status == 0)
    record_time(start_time, func_name)
    f:unget_chunk(l_chunk_num)
    gT:unget_chunk(l_chunk_num)
    gH:unget_chunk(l_chunk_num)
    if ( f_len < chunk_size ) then is_eor = true  end
    return reduce_struct, is_eor
  end
  --========================
  return Reducer ( { gen = lgen, func = getter, value = reduce_struct} )
end
return dt_benefit
