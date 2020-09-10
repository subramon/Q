local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local Reducer  = require 'Q/RUNTIME/RDCR/lua/Reducer'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local qmem    = require 'Q/UTILS/lua/qmem'
local chunk_size = qmem.chunk_size

local function evan_dt_benefit(
  V, -- V = values vector 
  S, -- S = sum vector 
  C, -- C = cnt vector 
  metric_name,  -- unused right now 
  min_size,
  sum,
  cnt
  )
  assert(type(V) == "lVector", "f must be a lVector ")
  assert(type(S) == "lVector", "g must be a lVector ")
  assert(type(C) == "lVector", "g must be a lVector ")
  assert(not V:has_nulls())
  assert(not S:has_nulls())
  assert(not C:has_nulls())
  assert(S:qtype() == "F8")
  assert(C:qtype() == "I4")
  -- TODO P3: Check that V is sorted ascending
  --=======================
  local sp_fn_name = "Q/ML/DT/lua/evan_dt_benefit_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, V:qtype(), metric_name, min_size,
    sum, cnt)
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
  local cst_V_as = subs.V_ctype .. " * "
  local cst_S_as = subs.S_ctype .. " * "
  local cst_C_as = subs.C_ctype .. " * "
  --=================================
  local l_chunk_num = 0

  local function lgen(chunk_num)
    local is_eor = false
    assert(chunk_num == l_chunk_num)
    local V_len, V_chunk = V:get_chunk(l_chunk_num)
    local S_len, S_chunk = S:get_chunk(l_chunk_num)
    local C_len, C_chunk = C:get_chunk(l_chunk_num)
    assert(V_len == S_len) -- vectors need to be same size 
    assert(S_len == C_len) -- vectors need to be same size 
    if ( V_len == 0 ) then -- no more input, return whatever is in out
      return reduce_struct, true 
    end
    local cst_V_chunk  = ffi.cast(cst_V_as,   get_ptr(V_chunk))
    local cst_S_chunk  = ffi.cast(cst_S_as,   get_ptr(S_chunk))
    local cst_C_chunk  = ffi.cast(cst_C_as,   get_ptr(C_chunk))
    local start_time = qc.RDTSC()
    local status = qc[func_name](cst_V_chunk, cst_S_chunk, cst_C_chunk,
        V_len, reduce_struct)
    assert(status == 0)
    record_time(start_time, func_name)
    V:unget_chunk(l_chunk_num)
    S:unget_chunk(l_chunk_num)
    C:unget_chunk(l_chunk_num)
    if ( V_len < chunk_size ) then is_eor = true  end
    return reduce_struct, is_eor
  end
  --========================
  return Reducer ( { gen = lgen, func = getter, value = reduce_struct} )
end
return evan_dt_benefit
