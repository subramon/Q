local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local cutils   = require 'libcutils'
local Scalar   = require 'libsclr'
local cVector  = require 'libvctr'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local max_num_in_chunk = qcfg.max_num_in_chunk

local function expander_where(a, b)
  assert(type(a) == "lVector")
  assert(type(b) == "lVector")
  assert(b:qtype() == "B1")
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
  
  local a_qtype = q:qtype()
  local width = cutils.get_width_qtype(a_qytpe)
  local max_num_in_chunk = qcfg.max_num_in_chunk
  local size = width * max_num_in_chunk
  -- XX local out_buf    = cmem.new(0)
  local cst_a_as   = cutils.str_qtype_to_str_ctype(a_qtype) .. "*"
  local cst_b_as   = cutils.str_qtype_to_str_ctype("B1") .. "*"
  --================================
  local a_chunk_idx = 0
  local l_chunk_num = 0
  local in_chunk_num = 0

  -- n_out counts number of entries in output buffer
  local n_out = ffi.new("uint64_t[?]", 1)
  -- TODO Is this needed?  n_out = ffi.cast("uint64_t *", n_out) 

  -- aidx counts how much of input buffer we have consumed
  -- useful because we may have consumed half of it and have
  -- to return because output bufer is full. When we come back
  -- we need to know where we left off
  local aidx = ffi.new("uint64_t[?]", 1)
  aidx[0] = 0 
  local num_in_out
  
  local function where_gen(chunk_num)
    n_out[0] = 0 
    assert(chunk_num == l_chunk_num)
    out_buf = cmem.new(size)
    out_buf:stealable(true)
    repeat
      local a_len, a_chunk, a_nn_chunk = a:get_chunk(in_chunk_num)
      local b_len, b_chunk, b_nn_chunk = b:get_chunk(in_chunk_num)
      if ( a_len == 0 ) then -- no more input, return whatever is in out
        local buf_size = tonumber(n_out[0])
        return buf_size, out_buf
      end
      assert(a_len == b_len)
      local cst_a_chunk = get_ptr(a_chunk, cst_a_as)
      local cst_b_chunk = get_ptr(b_chunk, cst_b_as)
      local cst_out_buf = get_ptr(out_buf, cst_a_as)
      local start_time = cutils.rdtsc()
      local status = qc[func_name](cst_a_chunk, cst_b_chunk, aidx, 
        a_len, cst_out_buf, chunk_size, n_out)
      assert(status == 0)
      record_time(start_time, func_name)
      num_in_out = tonumber(n_out[0])
      -- if you have consumed all you got from the a_chunk,
      -- then you need to move to the next chunk
      if ( tonumber(aidx[0]) == a_len ) then
        a:unget_chunk(in_chunk_num)
        b:unget_chunk(in_chunk_num)
        in_chunk_num = in_chunk_num + 1
        aidx[0] = 0
      end
      if ( a_len < chunk_size ) then
        return num_in_out, out_buf
      end
    until ( num_in_out == chunk_size )
    l_chunk_num = l_chunk_num + 1 
    return num_in_out, out_buf
  end
  return lVector( { gen = where_gen, has_nulls = false, qtype = a_qtype } )
end
return expander_where
