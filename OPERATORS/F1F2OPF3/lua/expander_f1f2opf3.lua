-- local dbg = require 'Q/UTILS/lua/debugger' local gen_code = require 'Q/UTILS/lua/gen_code'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_f1f2opf3(a, f1 , f2, optargs )
  local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  assert(f1)
  assert(type(f1) == "lVector", "f1 must be a lVector")
  assert(f2)
  assert(type(f2) == "lVector", "f2 must be a lVector")
  if ( optargs ) then assert(type(optargs) == "table") end
  local status, subs, tmpl = pcall(spfn, f1:fldtype(), f2:fldtype(), optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then 
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name) 
  end 
  -- STOP : Dynamic compilation
  assert(qc[func_name], "Symbol not available" .. func_name)
  local f3_qtype = assert(subs.out_qtype)
  local f3_width = qconsts.qtypes[f3_qtype].width
  f3_width = f3_width or 1 -- to account for B1 and such types

  local buf_sz = qconsts.chunk_size * f3_width
  local f3_buf = nil
  local nn_f3_buf = nil -- Will be created if nulls in input

  local first_call = true
  local chunk_idx = 0
  local myvec  -- see note expander_f1f2opf3.txt
  local f3_gen = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      first_call = false
      f3_buf = assert(cmem.new(buf_sz, f3_qtype, func_name))
      -- Commenting out below assert as test_safe_convert is failing
      --assert( ((f1:has_nulls() == false) and (f2:has_nulls() == false)),
      --"not ready for nulls as yet")
      myvec:no_memcpy(f3_buf) -- hand control of this f3_buf to the vector 
    end
    local f1_len, f1_chunk, nn_f1_chunk
    local f2_len, f2_chunk, nn_f2_chunk
    f1_len, f1_chunk, nn_f1_chunk = f1:chunk(chunk_idx)
    f2_len, f2_chunk, nn_f2_chunk = f2:chunk(chunk_idx)
    local f1_cast_as = subs.in1_ctype .. "*"
    local f2_cast_as = subs.in2_ctype .. "*"
    local f3_cast_as = subs.out_ctype .. "*"
    assert(f1_len == f2_len)
    if f1_len > 0 then
      local chunk1 = ffi.cast(f1_cast_as,  get_ptr(f1_chunk))
      local chunk2 = ffi.cast(f2_cast_as,  get_ptr(f2_chunk))
      local chunk3 = ffi.cast(f3_cast_as,  get_ptr(f3_buf))
      local start_time = qc.RDTSC()
      qc[func_name](chunk1, chunk2, f1_len, chunk3)
      record_time(start_time, func_name)
    end
    if ( f1_len < qconsts.chunk_size ) then 
      -- TODO P2 Following is experimental code. Basic idea is to 
      -- free up resources of a Vector as soon we know its not needed 
      if ( f1:is_mono() ) then f1:delete() end 
      if ( f2:is_mono() ) then f2:delete() end 
    end
    chunk_idx = chunk_idx + 1
    return f1_len, f3_buf, nn_f3_buf
  end
  myvec = lVector{gen=f3_gen, nn=false, qtype=f3_qtype, has_nulls=false}
  return myvec
end

return expander_f1f2opf3
