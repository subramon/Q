-- Provides a slow but easy way to convert a string into a number
local ffi           = require 'ffi'
local cmem          = require 'libcmem'
local cutils        = require 'libcutils'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local lVector       = require 'Q/RUNTIME/VCTRS/lua/lVector'
local function SC_to_lkp_L(
  invec, 
  lkp_tbl,
  subs
  )
  assert(type(invec) == "lVector")
  assert(type(lkp_tbl) == "table")
  assert(type(subs) == "table")

  local rev_lkp_tbl = {}
  for k, v in ipairs(lkp_tbl) do 
    rev_lkp_tbl[v] = k
  end

  local l_chunk_num = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    -- START ALlocate output 
    local buf = cmem.new({ size = subs.bufsz, qtype = subs.out_qtype})
    buf:zero()
    buf:stealable(true)
    local out_ptr = get_ptr(buf, subs.cast_buf_as)
    local nn_buf, nn_out_ptr
    if ( subs.has_nulls ) then 
      nn_buf = cmem.new({ 
        size = subs.nn_bufsz, qtype = subs.nn_out_qtype})
      nn_buf:zero()
      nn_buf:stealable(true)
      nn_out_ptr = get_ptr(nn_buf, subs.cast_nn_buf_as)
    end
    -- STOP  Allocate output 
    -- START Gather input 
    local cast_buf = get_ptr(buf, subs.cast_buf_as)
    local in_len, in_chunk, nn_in_chunk = invec:get_chunk(l_chunk_num)
    if ( in_len == 0 ) then 
      buf:delete()
      if ( subs.has_nulls ) then 
        nn_buf:delete()
      end
      return 0, nil 
    end 
    local in_ptr  = get_ptr(in_chunk, "char *")
    local nn_in_ptr  = ffi.NULL 
    if ( nn_in_chunk ) then
      nn_in_ptr  = get_ptr(nn_in_chunk, "bool *")
    end
    -- STOP  Gather input 
    for i = 1, in_len do
      -- Below: note -1 for C/Lua indexing
      if ( subs.has_nulls ) then
        if ( nn_in_ptr[i-1] == false ) then
        -- nothing to do 
        else
          local in_str = ffi.string(in_ptr) -- , subs.in_width)
          local out_idx = rev_lkp_tbl[in_str]
          if ( not out_idx ) then 
            out_ptr[i-1] = 0
            nn_out_ptr[i-1] = false
          else
            out_ptr[i-1] = out_idx 
            nn_out_ptr[i-1] = true 
          end
        end
      else
        local in_str = ffi.string(in_ptr) -- , subs.in_width)
        local lkp_val = assert(rev_lkp_tbl[in_str])
        out_ptr[i-1] = lkp_val -- note -1 for C/Lua indexing
      end
      in_ptr = in_ptr + subs.in_width
    end
    invec:unget_chunk(l_chunk_num)
    l_chunk_num = l_chunk_num + 1
    return in_len, buf, nn_buf
  end
  local vargs = {}
  vargs.qtype = subs.out_qtype
  vargs.gen = gen
  vargs.has_nulls = subs.has_nulls
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return SC_to_lkp_L
