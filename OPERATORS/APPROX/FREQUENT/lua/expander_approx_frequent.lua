local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'
local Reducer = require 'Q/RUNTIME/lua/Reducer'
local qc      = require 'Q/UTILS/lua/q_core'

local qtypes  = require 'Q/OPERATORS/APPROX/FREQUENT/lua/qtypes'
local spfn    = require 'Q/OPERATORS/APPROX/FREQUENT/lua/specializer_approx_frequent'

local function expander_approx_frequent(x, min_freq, err)
  local status, subs, tmpl = pcall(spfn, x:fldtype())
  local func_name = subs.fn

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  --STOP: Dynamic compilation

  local data = assert(ffi.malloc(ffi.sizeof(subs.data_ty)), "malloc failed")
  data = ffi.cast(subs.data_ty..'*', data)
  qc[subs.alloc_fn](x:length(), min_freq, err, x:chunk_size(), data)
  local chunk_idx = 0
  local function out_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    local len, chunk, nn_chunk = x:chunk(chunk_idx)
    chunk_idx = chunk_idx + 1
    if len > 0 then
      qc[subs.chunk_fn](chunk, len, data)
      return data
    else
      return nil
    end
  end

  local function getter(data)

    local y_ty = subs.elem_ctype..'*'
    local y = assert(ffi.malloc(ffi.sizeof(y_ty)), "malloc failed")
    local y_copy = ffi.cast(y_ty..'*', y)
    
    local f_ty = subs.freq_ctype..'*'
    local f = assert(ffi.malloc(ffi.sizeof(f_ty)), "malloc failed")
    local f_copy = ffi.cast(f_ty..'*', f)
    
    local len_ty = subs.out_len_ctype
    local len = assert(ffi.malloc(ffi.sizeof(len_ty)), "malloc failed")
    len = ffi.cast(len_ty..'*', len)    

    qc[subs.out_fn](data, y, f, len)

    local y_col = lVector({qtype = subs.elem_qtype, gen = true, has_nulls = false})
    y_col:put_chunk(y, nil, len[0])
    y_col:eov()

    local f_col = lVector({qtype = subs.freq_qtype, gen = true, has_nulls = false})
    f_col:put_chunk(f, nil, len[0])
    f_col:eov()

    qc[subs.free_fn](data)
    return y_col, f_col, len[0]
  end

  return Reducer({ gen = out_gen, func = getter })
end

return expander_approx_frequent
