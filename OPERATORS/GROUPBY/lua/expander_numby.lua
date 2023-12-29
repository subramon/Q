local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Reducer  = require 'Q/RUNTIME/RDCR/lua/Reducer'
local qc       = require 'Q/UTILS/lua/qcore'
local cmem     = require 'libcmem'
local cVector  = require 'libvctr'
local cutils   = require 'libcutils'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_numby(val, nb, cnd, optargs)
  if ( not optargs ) then optargs = {} end 
  assert(type(optargs) == "table")
  -- nb is a number and we assume that the value of a are in
  -- [0 .. nb-1 ]
  local sp_fn_name = "Q/OPERATORS/GROUPBY/lua/numby_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(val, nb, cnd, optargs))
  local func_name = assert(subs.fn)
  qc.q_add(subs); 

  -- allocate buffer for output
  local g_rdcr_err = false
  local out_buf = assert(cmem.new(
  { size = subs.out_buf_size, qtype = subs.out_qtype}))
  out_buf:zero() -- IMPORTANT 
  out_buf:stealable(true) 
  local cast_out_buf = get_ptr(out_buf, subs.cast_out_as)

  local destructor = function(rdcr_val)
    assert(type(rdcr_val) == "CMEM")
    rdcr_val:delete()
    -- print("Destrictor returning")
    return true
  end
  --=====================================================
  local vectorizer = function(rdcr_val)
    if ( g_rdcr_err ) then return nil end 
    assert(type(rdcr_val) == "CMEM")
    local vnum = lVector.new( {qtype = subs.out_qtype, gen = true, 
    has_nulls = false, max_num_in_chunk = subs.max_num_in_chunk})
    vnum:put_chunk(rdcr_val, nb)
    vnum:eov()
    return vnum
  end
  local l_chunk_num = 0
  --========================================================
  local function gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    assert(chunk_num == l_chunk_num)
    local val_len, val_chunk = val:get_chunk(l_chunk_num)
    if ( val_len == 0 ) then return nil end -- indicates end for Reducer
    local cast_val_chnk = get_ptr(val_chunk, subs.cast_val_as)

    local cast_cnd_chnk = ffi.NULL
    if ( cnd ) then 
      cnd_len, cnd_chunk = cnd:get_chunk(l_chunk_num)
      assert(val_len == cnd_len)
      cast_cnd_chnk = get_ptr(cnd_chunk, subs.cast_cnd_as)
    end
    local start_time = cutils.rdtsc()
    local status = qc[func_name](cast_val_chnk, val_len, cast_cnd_chnk,
      cast_out_buf, nb)
    record_time(start_time, func_name)
    -- release resources
    val:unget_chunk(chunk_num)
    if ( cnd ) then 
      cnd:unget_chunk(chunk_num)
    end
    -- check for error 
    if ( status ~= 0 ) then 
      g_rdcr_err = true; return nil
    end
    if val_len < val:max_num_in_chunk() then -- this is last chunk of a
      return nil
    end
    l_chunk_num = l_chunk_num + 1 
    return out_buf
  end
  local rargs = {}
  rargs.gen = gen
  rargs.destructor = destructor
  rargs.func = vectorizer
  rargs.value = out_buf
  local r =  Reducer (rargs)
  return r
end

return expander_numby
