local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc       = require 'Q/UTILS/lua/qcore'
local cmem     = require 'libcmem'
local cutils   = require 'libcutils'
local Scalar   = require 'libsclr'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function lmin(x, y) if ( x < y ) then return x else return y end end

local function expander_where(a, b, optargs)
  assert(type(a) == "lVector")
  assert(type(b) == "lVector")
  local sp_fn_name = "Q/OPERATORS/WHERE/lua/where_specialize"
  local spfn = assert(require(sp_fn_name))

  -- TODO P3 Write a test for case of pre-computed
  -- Check min and max value from bit vector metadata
  local minval = b:get_meta("min")
  local maxval = b:get_meta("max")
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
  local subs = assert(spfn(a, b, optargs))
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  
  --================================
  -- note that a and b have to have the same max_num_in_chunk but 
  -- output does not. Hence, we need to track the following individually
  local ab_chunk_num = 0 
  local l_chunk_num = 0

  -- aidx must be in the closure of the generator 
  -- aidx tells us which element of input buffer(s) we need to examine
  -- useful because we may have consumed half of it and have
  -- to return because output bufer is full. When we come back
  -- we need to know where we left off
  local aidx = cmem.new(ffi.sizeof("uint64_t"))
  local c_aidx = ffi.cast("uint64_t *", get_ptr(aidx, "UI8"))
  c_aidx[0] = 0 
  
  local a_name = a:name()
  local b_name = b:name()
  local function gen(chunk_num)
    print("WHERE: Generating chunk ", chunk_num)
    assert(chunk_num == l_chunk_num)
    -- n_out counts number of entries in output buffer
    local n_out = cmem.new(ffi.sizeof("uint64_t"))
    local c_n_out = ffi.cast("uint64_t *", get_ptr(n_out, "UI8"))
    c_n_out[0] = 0 
    local out_buf = cmem.new(subs.size)
    out_buf:zero()
    out_buf:stealable(true)
    local num_in_out = 0
    repeat
      print("WHERE: Getting Input chunk/idx = ", ab_chunk_num, c_aidx[0])
      local a_len, a_chunk, a_nn_chunk = a:get_chunk(ab_chunk_num)
      local b_len, b_chunk, b_nn_chunk = b:get_chunk(ab_chunk_num)
      assert(a_len == b_len) -- See Detailed note at end 
      local ab_len = a_len -- lmin(a_len, b_len)
      -- See Detailed Note at end for why ab_len is needed
      if ( ab_len == 0 ) then 
        -- no more input, flush whatever is in output buffer
        local num_in_out = tonumber(c_n_out[0])
        aidx:delete()
        n_out:delete()
        a:early_free() -- EXPERIMENTAL Jan 8 2024
        b:early_free() -- EXPERIMENTAL Jan 8 2024
        return num_in_out, out_buf
      end
      --================================================
      local cast_a_buf   = get_ptr(a_chunk, subs.cast_a_as)
      local cast_b_buf   = get_ptr(b_chunk, subs.cast_b_as)
      local cast_out_buf = get_ptr(out_buf, subs.cast_a_as)
      local start_time = cutils.rdtsc()
      local status = qc[func_name](cast_a_buf, cast_b_buf, c_aidx, 
        ab_len, cast_out_buf, subs.max_num_in_chunk, c_n_out)
      assert(status == 0)
      record_time(start_time, func_name)
      num_in_out = tonumber(c_n_out[0])
      assert(num_in_out <= subs.max_num_in_chunk)
      -- print("num_in_out = ",  num_in_out)
      -- if you have consumed all you got from the a_chunk,
      -- then you need to move to the next chunk
      print("WHERE: Ungetting ", ab_chunk_num)
      a:unget_chunk(ab_chunk_num)
      b:unget_chunk(ab_chunk_num)
      if ( tonumber(c_aidx[0]) == ab_len ) then
        ab_chunk_num = ab_chunk_num + 1
        c_aidx[0] = 0
      end
      if ( ab_len < a:max_num_in_chunk() ) then 
        -- no more input, flush whatever is in output buffer
        -- print(" no more input, flush whatever is in output buffer")
        local num_in_out = tonumber(c_n_out[0])
        aidx:delete()
        n_out:delete()
        a:early_free() -- EXPERIMENTAL Jan 8 2024
        b:early_free() -- EXPERIMENTAL Jan 8 2024
        print("No more input: returning from WHERE")
        return num_in_out, out_buf
      end
    until ( num_in_out == subs.max_num_in_chunk )
    print("Returning from WHERE")
    l_chunk_num = l_chunk_num + 1 
    return num_in_out, out_buf
  end
  local vargs = {}
  vargs.gen = gen
  vargs.has_nulls = false
  vargs.qtype = subs.a_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return expander_where

--[[

Explanation for the introduction of ab_len

I had a case where I was doing Q.where(x, y) which were supposed to be
the same length. But, I did not know the length of y and x was
supposed to be a primary key i.e., Q.seq({ start = 0, by = 1, len =
n}). The rub was that I did not know what n would be because x and y
were both memo-ized. The solution was to make "n" much larger than it
could ever be e.g., LLONG_MAX. But now x and y would not be the same
length :-( The solution was to stop when either "x" or "y" stopped
--]]
