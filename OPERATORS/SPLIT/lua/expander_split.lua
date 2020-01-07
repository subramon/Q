local gen_code = require 'Q/UTILS/lua/gen_code'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function expander_split(a, f1)
  --[[
  local sp_fn_name = "Q/OPERATORS/SPLIT/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  if ( optargs ) then assert(type(optargs) == "table") end
  --]]
  assert(f1)
  assert(type(f1) == "lVector", "f1 must be a lVector")
  --[[
  local status, subs, tmpl = pcall(spfn, f1:fldtype(), f2:fldtype(), optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then 
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name) 
  end 
  assert(qc[func_name], "Symbol not available" .. func_name)
  --]]
  local o1_qtype = f1:fldtype()
  local o2_qtype = "I8"

  local o1_bufsz = qconsts.chunk_size * qconts.qtypes[o1_qtype].width
  local o2_bufsz = qconsts.chunk_size * qconts.qtypes[o2_qtype].width

  local o1_buf
  local o2_buf

  local first_call = true
  local chunk_idx = 0

  local v1
  local v2
  
  local o1o2_gen = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      first_call = false
      o1_buf = cmem.new(o1_bufsz, o1_qtype)
      o2_buf = cmem.new(o2_bufsz, o2_qtype)
    end
    assert(o1_buf)
    assert(o2_buf)
    local f1_len, f1_chunk, nn_f1_chunk
    f1_len, f1_chunk, nn_f1_chunk = f1:chunk(chunk_idx)
    v1:put_chunk(f1_chunk, nn_f1_chunk, f1_len)
    v2:put_chunk(f1_chunk, nn_f1_chunk, f1_len)
  end
  v1 = lVector({gen=o1o2_gen, gen_returns_chunk=false, nn=false, qtype=o1_qtype, has_nulls=false}),
  v2 = lVector({gen=o1o2_gen, gen_returns_chunk=false, nn=false, qtype=o2_qtype, has_nulls=false}),
  return { v1, v2 }
end

return expander_split
