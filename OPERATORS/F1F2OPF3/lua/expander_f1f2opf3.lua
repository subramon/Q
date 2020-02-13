local qconsts = require 'Q/UTILS/lua/q_consts'
local cVector = require 'libvctr'
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
  assert(type(f1) == "lVector", "f1 must be a lVector")
  assert(not f1:has_nulls())
  assert(type(f2) == "lVector", "f2 must be a lVector")
  assert(not f2:has_nulls())
  if ( optargs ) then assert(type(optargs) == "table") end
  local status, subs = pcall(spfn, f1:fldtype(), f2:fldtype(), optargs)
  if not status then print(subs) end
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then 
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end 
  -- STOP : Dynamic compilation
  assert(qc[func_name], "Symbol not available" .. func_name)

  local f3_qtype = assert(subs.out_qtype)
  local f3_width = qconsts.qtypes[f3_qtype].width
  f3_width = f3_width or 1 -- to account for B1 and such types

  local buf_sz = chunk_size * f3_width
  local buf = assert(cmem.new(0)) -- note we don't really allocate data

  local first_call = true
  local l_chunk_num = 0
  local myvec  -- see note expander_f1f2opf3.txt
  local f3_gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    --=== START: buffer allocation
    if ( not buf:is_data() ) then 
      buf = assert(cmem.new({size = buf_sz, qtype = subs.out_qtype}))
      buf:stealable(true)
    end
    --=== STOP : buffer allocation
    --=============================
    local f1_len, f1_chunk, nn_f1_chunk
    local f2_len, f2_chunk, nn_f2_chunk
    f1_len, f1_chunk, nn_f1_chunk = f1:get_chunk(l_chunk_num)
    f2_len, f2_chunk, nn_f2_chunk = f2:get_chunk(l_chunk_num)
    local f1_cast_as = subs.in1_ctype .. "*"
    local f2_cast_as = subs.in2_ctype .. "*"
    local f3_cast_as = subs.out_ctype .. "*"
    assert(f1_len == f2_len)
    if f1_len > 0 then
      local chunk1 = get_ptr(f1_chunk, f1_cast_as)
      local chunk2 = get_ptr(f2_chunk, f2_cast_as)
      local chunk3 = get_ptr(f3_chunk, f3_cast_as)
      local start_time = qc.RDTSC()
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
  myvec = lVector{gen=f3_gen, nn=false, qtype=f3_qtype, has_nulls=false}
  return myvec
end

return expander_f1f2opf3
