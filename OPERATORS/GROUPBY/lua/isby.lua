local ffi      = require 'ffi'
local cmem     = require 'libcmem'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc       = require 'Q/UTILS/lua/qcore'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'

local function isby(src_val, src_lnk, dst_lnk, optargs)
  -- Verification
  local sp_fn_name = "Q/OPERATORS/GROUPBY/lua/isby_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs = pcall(spfn, src_val, src_lnk, dst_lnk, optargs)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  -- START: Dynamic compilation
  local func_name = assert(subs.fn)
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  assert(qc[func_name], "Symbol not defined " .. func_name)
  -- STOP: Dynamic compilation

  local src_chunk_idx = 0 -- which  src chunk to request
  local dst_chunk_idx = 0 -- which  src chunk to request
  local src_idx       = 0 -- how much of src chunk has been consumed
  local dst_idx       = 0 -- how much of dst chunk has been consumed

  local function gen(chunk_num)
    -- sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == dst_chunk_idx)
    dst_idx = 0

    local dv_chunk = assert(cmem.new(subs.bufsz))
    dv_chunk:zero()
    dv_chunk:stealable(true)
    local dvbuf = get_ptr(dv_chunk, subs.dst_val_qtype)

    local nn_chunk = assert(cmem.new(subs.nn_bufsz))
    nn_chunk:zero()
    nn_chunk:stealable(true)
    local nnbuf = get_ptr(nn_chunk, "BL")

    -- sl = src_lnk, dl = dst_lnk, sv = src_val, dv = dst_val
    local dl_len, dl_chunk = dst_lnk:get_chunk(dst_chunk_idx)
    if ( dl_len == 0 ) then return 0 end 
    local dlbuf = get_ptr(dl_chunk, subs.dst_lnk_qtype)

    local iter = 1 -- for debugging 
    while ( true ) do 
      local sl_len, sl_chunk = src_lnk:get_chunk(src_chunk_idx)
      local sv_len, sv_chunk = src_val:get_chunk(src_chunk_idx)
      assert(sl_len == sv_len)
      if ( sl_len == 0 ) then
        dst_chunk_idx = dst_chunk_idx + 1
        -- NOTE that you are returning null values since you
        -- have no  source values to match against
        return dl_len, dv_chunk, nn_chunk
      end
      local slbuf = get_ptr(sl_chunk, subs.src_lnk_qtype)
      local svbuf = get_ptr(sv_chunk, subs.src_val_qtype)
  
      local c_dst_idx = ffi.new("uint32_t[?]", 1)
      c_dst_idx = ffi.cast("uint32_t *", c_dst_idx)
      c_dst_idx[0] = dst_idx

      local c_src_idx = ffi.new("uint32_t[?]", 1)
      c_src_idx = ffi.cast("uint32_t *", c_src_idx)
      c_src_idx[0] = src_idx

      local status = qc[func_name]( slbuf, svbuf, sl_len, dlbuf, dvbuf, 
        nnbuf, dl_len, c_src_idx, c_dst_idx)
      assert(status == 0)
      dst_idx = tonumber(c_dst_idx[0])
      src_idx = tonumber(c_src_idx[0])
      if ( src_idx == sl_len ) then
        src_lnk:unget_chunk(src_chunk_idx)
        src_val:unget_chunk(src_chunk_idx)
        src_chunk_idx = src_chunk_idx + 1
        src_idx       = 0
      end
      if ( dst_idx == dl_len ) then break end 
      iter = iter + 1 
    end
    dst_chunk_idx = dst_chunk_idx + 1
    return dl_len, dv_chunk, nn_chunk
  end
  local vargs = { gen = gen, has_nulls = false, 
    qtype = subs.dst_val_qtype, max_num_in_chunk = subs.max_num_in_chunk }
  if ( optargs ) then 
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do 
      assert(k ~= gen)
      assert(k ~= qtype)
      vargs[k] = v
    end
  end
  return lVector(vargs)
end
return isby
