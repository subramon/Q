local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local cutils   = require 'libcutils'
local Scalar   = require 'libsclr'
local cVector  = require 'libvctr'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local chunk_size = cVector.chunk_size()

local function expander_where(a, b)
  local sp_fn_name = "Q/OPERATORS/WHERE/lua/where_specialize"
  local spfn = assert(require(sp_fn_name))

  -- Check min and max value from bit vector metadata
  -- TODO P3 Write a test for case of pre-computed
  local minval = b:get_meta("__min")
  local maxval = b:get_meta("__min")
  if ( minval and maxval) then 
    if ( minval == Scalar.new(1) ) and ( maxval == Scalar.new(1) ) then
      return a
    end
    if ( minval == Scalar.new(0) ) and ( maxval == Scalar.new(0) ) then
      return nil
    end
  end

  local subs = assert(spfn(a, b))
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  
  local out_buf    = cmem.new(0)
  local sz_out_buf = chunk_size * qconsts.qtypes[a:qtype()].width
  local cst_a_as   = qconsts.qtypes[a:fldtype()].ctype .. "*"
  local cst_b_as   = "uint64_t *" -- this is a bit vector 
  --================================
  local a_chunk_idx = 0
  local l_chunk_num = 0
  local in_chunk_num = 0

  -- n_out counts number of entries in output buffer
  local n_out = cmem.new(ffi.sizeof("uint64_t"))
  local cst_n_out = get_ptr(n_out, "I8")

  -- aidx counts how much of input buffer we have consumed
  -- useful because we may have consumed half of it and have
  -- to return because output bufer is full. When we come back
  -- we need to know where we left off
  local aidx = cmem.new(ffi.sizeof("uint64_t"))
  local cst_aidx = get_ptr(aidx, "I8")
  cst_aidx[0] = 0 -- TODO Where should this be?
  local num_in_out
  
  local function where_gen(chunk_num)
    cst_n_out[0] = 0 
    assert(chunk_num == l_chunk_num)
    if ( not out_buf:is_data() ) then 
      out_buf = assert(cmem.new( { size = sz_out_buf, qtype = a:qtype()}))
      out_buf:stealable(true)
    end
    repeat
      local a_len, a_chunk, a_nn_chunk = a:get_chunk(in_chunk_num)
      local b_len, b_chunk, b_nn_chunk = b:get_chunk(in_chunk_num)
      if ( a_len == 0 ) then -- no more input, return whatever is in out
        local buf_size = tonumber(cst_n_out[0])
        n_out:delete()
        aidx:delete()
        return buf_size, out_buf
      end
      assert(a_len == b_len)
      local cst_a_chunk = ffi.cast(cst_a_as, get_ptr(a_chunk))
      local cst_b_chunk = ffi.cast(cst_b_as, get_ptr(b_chunk))
      local cst_out_buf = ffi.cast(cst_a_as, get_ptr(out_buf))
      local start_time = cutils.rdtsc()
      local status = qc[func_name](cst_a_chunk, cst_b_chunk, cst_aidx, 
        a_len, cst_out_buf, chunk_size, cst_n_out)
      assert(status == 0)
      record_time(start_time, func_name)
      num_in_out = tonumber(cst_n_out[0])
      -- if you have consumed all you got from the a_chunk,
      -- then you need to move to the next chunk
      if ( tonumber(cst_aidx[0]) == a_len ) then
        a:unget_chunk(in_chunk_num)
        b:unget_chunk(in_chunk_num)
        in_chunk_num = in_chunk_num + 1
        cst_aidx[0] = 0
      end
      if ( a_len < chunk_size ) then
        return num_in_out, out_buf
      end
    until ( num_in_out == chunk_size )
    l_chunk_num = l_chunk_num + 1 
    return num_in_out, out_buf
  end
  return lVector( { gen = where_gen, has_nulls = false, qtype = a:qtype() } )
end
return expander_where
