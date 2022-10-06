local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc       = require 'Q/UTILS/lua/qcore'
local cmem     = require 'libcmem'
local cutils   = require 'libcutils'
local Scalar   = require 'libsclr'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_where(a, b, optargs)
  assert(type(a) == "lVector")
  assert(type(b) == "lVector")
  local sp_fn_name = "Q/OPERATORS/WHERE/lua/where_specialize"
  local spfn = assert(require(sp_fn_name))

  -- TODO P3 Write a test for case of pre-computed
  -- Check min and max value from bit vector metadata
  local minval = b:get_meta("min")
  local maxval = b:get_meta("min")
  if ( minval and maxval) then 
    assert(type(minval) == "Scalar")
    assert(type(maxval) == "Scalar")
    -- if b is all true, return a. If b is all false, return  nil
    if ( ( minval:to_num() == 1 ) and ( maxval:to_num() == 1 ) ) then 
      return a
    end
    if ( ( minval:to_num() == 0 ) and ( maxval:to_num() == 0 ) ) then 
      return nil
    end
  end
  --==============================================
  local subs = assert(spfn(a, b))
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  
  --================================
  local a_chunk_idx = 0
  local l_chunk_num = 0


  -- aidx counts how much of input buffer we have consumed
  -- useful because we may have consumed half of it and have
  -- to return because output bufer is full. When we come back
  -- we need to know where we left off
  local aidx = cmem.new(ffi.sizeof("uint64_t"))
  aidx = ffi.cast("uint64_t *", get_ptr(aidx, "UI8"))
  aidx[0] = 0 
  
  local num_in_out
  local function where_gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    -- n_out counts number of entries in output buffer
    local n_out = cmem.new(ffi.sizeof("uint64_t"))
    n_out = ffi.cast("uint64_t *", get_ptr(n_out, "UI8"))
    n_out[0] = 0 
    local out_buf = cmem.new(subs.size)
    out_buf:stealable(true)
    repeat
      local a_len, a_chunk, a_nn_chunk = a:get_chunk(l_chunk_num)
      local b_len, b_chunk, b_nn_chunk = b:get_chunk(l_chunk_num)
      if ( a_len == 0 ) then -- no more input, return whatever is in out
        local buf_size = tonumber(n_out[0])
        return buf_size, out_buf
      end
      assert(a_len == b_len)
      local cast_a_buf   = get_ptr(a_chunk, subs.cast_a_as)
      local cast_b_buf   = get_ptr(b_chunk, subs.cast_b_as)
      local cast_out_buf = get_ptr(out_buf, subs.cast_a_as)
      local start_time = cutils.rdtsc()
      local status = qc[func_name](cast_a_buf, cast_b_buf, aidx, 
        a_len, cast_out_buf, subs.max_num_in_chunk, n_out)
      assert(status == 0)
      record_time(start_time, func_name)
      num_in_out = tonumber(n_out[0])
      -- if you have consumed all you got from the a_chunk,
      -- then you need to move to the next chunk
      if ( tonumber(aidx[0]) == a_len ) then
        a:unget_chunk(l_chunk_num)
        b:unget_chunk(l_chunk_num)
        l_chunk_num = l_chunk_num + 1
        aidx[0] = 0
      end
      if ( a_len < subs.max_num_in_chunk ) then
        return num_in_out, out_buf
      end
    until ( num_in_out == subs.max_num_in_chunk )
    -- l_chunk_num = l_chunk_num + 1 
    return num_in_out, out_buf
  end
  return lVector( { gen = where_gen, has_nulls = false, qtype = subs.a_qtype } )
end
return expander_where
