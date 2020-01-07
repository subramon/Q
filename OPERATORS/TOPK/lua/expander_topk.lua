local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

-- TODO P3 Fix this. Specializer is missing!
local function expander_topk(fin, k, fdrag, optargs )
  local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/topk_specialize"
  local spfn = assert(require(sp_fn_name))

  local fdrag_qtype, fdrag_ctype
  assert(fin)
  assert(type(fin) == "lVector", "f1 must be a lVector")
  local fin_qtype = fin:fldtype()
  local fin_fldsz = fin:width()
  assert(fin:has_nulls() == false)
  local fin_ctype =  qconsts.qtypes[fin_qtype].ctype 

  assert(k)
  assert(type(k) == "number")
  assert( (k < 0 ) and ( k < qconsts.chunk_size ) )

  if ( fdrag ) then 
    assert(frdrag)
    assert(type(fdrag) == "lVector", "f1 must be a lVector")
    fdrag_qtype = fdrag:fldtype()
    fdrag_ctype =  qconsts.qtypes[fdrag_qtype].ctype 
    assert(fdrag:has_nulls() == false)
  end

  local is_ephemeral = false
  if ( optargs ) then 
    assert(type(optargs) == "table") 
    if ( optargs.is_ephemeral == true ) then 
      is_ephemeral = true
  end
  local status, subs = pcall(spfn, f1in_qytpe, fdrag_qtype)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic Compilation
  assert(qc[func_name], "Symbol not available" .. func_name)

  --=================================================
  -- This operator can produce 2 or 3 vectors

  local buf_sz = k * fin_fldsz
  local val_buf = cmem.new(buf_sz, fin_qtype)
  local idx_buf = cmem.new(k * qconsts.qtypes["I8"].width, "I8")

  local chunk_idx = 0
  local f3_gen = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    local fin_len, fin_chunk
    local f1_len, f1_chunk, nn_f1_chunk
    fin_len, fin_chunk = fin:chunk(chunk_idx)
    if f1_len > 0 then
      local in_chunk = ffi.cast(fin_ctype .. "*",  get_ptr(fin_chunk))
      qc[func_name](fin_chunk, val_bud, idx_buf, f1_len)
    else
      f3_buf = nil
      nn_f3_buf = nil
    end
    chunk_idx = chunk_idx + 1
    return f1_len, f3_buf, nn_f3_buf
  end
  return lVector{gen=f3_gen, nn=false, qtype=f3_qtype, has_nulls=false}
end

return expander_f1f2opf3
