local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'

local function isby(src_val, src_lnk, dst_lnk, optargs)
  -- Verification
  local sp_fn_name = "Q/OPERATORS/GROUPBY/lua/isby_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs = pcall(spfn, src_val, src_lnk, dst_lnk, optargs)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  assert(qc[subs.fn], "Symbol not defined " .. subs.fn)
  -- STOP: Dynamic compilation

  local src_chunk_idx = 0 -- which  src chunk to request
  local dst_chunk_idx = 0 -- which  src chunk to request
  local src_idx       = 0 -- how much of src chunk has been consumed
  local dst_idx       = 0 -- how much of dst chunk has been consumed

  local function minby_gen(chunk_num)
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
    local nnbuf = get_ptr(buf, "BL")

    -- sl = src_lnk, dl = dst_lnk, sv = src_val, dv = dst_val
    local dl_len, dl_chunk, = dst_lnk:get_chunk(dst_chunk_idx)
    if ( dl_len == 0 ) then return 0 end 
    local dlbuf = get_ptr(dl_chunk, subs.dst_lnk_qtype)

    while ( true ) do 
      local sl_len, sl_chunk, = src_lnk:get_chunk(src_chunk_idx)
      local sv_len, sv_chunk, = src_val:get_chunk(src_chunk_idx)
      assert(sl_len == sv_len)
      if ( s1_len == 0 ) then
        dst_chunk_idx = dst_chunk_idx + 1
        -- NOTE that you are returning null values since you
        -- have no  source values to match against
        return dl_len, dv_chunk, nn_chunk
      end
      local slbuf = get_ptr(sl_chunk, subs.src_lnk_qtype)
      local svbuf = get_ptr(sv_chunk, subs.src_val_qtype)
  
      local status = qc[subs.fn](
        slbuf, svbuf, sl_len, dlbuf, dvbuf, dv_len, dst_idx, src_idx)
      assert(status == 0)
      if ( src_idx == sl_len ) then
        src_chunk_idx = src_chunk_idx + 1
        src_idx       = 0
      end
      if ( dst_idx == dv_len ) then break end 
    end
    dst_chunk_idx = dst_chunk_idx + 1
    return dv_len, dv_chunk, nn_chunk
  end
  local vargs = { gen = isby_gen, has_nulls = false, 
    qtype = subs.dst_val_qtype}
  for k, v in pairs(optargs) do 
    assert(k ~= gen)
    assert(k ~= qtype)
    vargs[k] = v
  end
  return lVector(vargs)
end
return expander_isby
