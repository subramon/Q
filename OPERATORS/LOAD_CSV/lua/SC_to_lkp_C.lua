-- Provides a slow but easy way to convert a string into a number
local ffi           = require 'ffi'
local cmem          = require 'libcmem'
local cutils        = require 'libcutils'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local qc            = require 'Q/UTILS/lua/qcore'
local tbl_of_str_to_C_array = require 'Q/UTILS/lua/tbl_of_str_to_C_array'
local lVector       = require 'Q/RUNTIME/VCTRS/lua/lVector'
local function SC_to_lkp_C(
  invec, 
  lkp_tbl,
  subs
  )
  assert(type(invec) == "lVector")
  assert(type(lkp_tbl) == "table")
  assert(type(subs) == "table")
  
  qc.q_add(subs)
  --[[ There is a serious bug in LuaJIT's gc or in my understanding of it
  I would have liked to create lkp here, outside the function gen()
    However, if I do, then it gets gc'd not right away but on the nth call
    where n varies. So I had to create it within the function gen()
    which is inefficient 
    local lkp, n_lkp = tbl_of_str_to_C_array(lkp_tbl)
    TODO P1 This needs to be fixed one way or another.
    --]]


  local l_chunk_num = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    local lkp, n_lkp = tbl_of_str_to_C_array(lkp_tbl)
    -- START ALlocate output 
    local buf = cmem.new({ size = subs.bufsz, qtype = subs.out_qtype})
    buf:zero()
    buf:stealable(true)
    local out_ptr = get_ptr(buf, subs.cast_buf_as)
    local nn_buf; local nn_out_ptr = ffi.NULL
    if ( subs.has_nulls ) then 
      nn_buf = cmem.new({ 
        size = subs.nn_bufsz, qtype = subs.nn_out_qtype})
      nn_buf:zero()
      nn_buf:stealable(true)
      nn_out_ptr = get_ptr(nn_buf, subs.nn_cast_buf_as)
      print("nn_out_ptr = ", nn_out_ptr)
    end
    -- STOP  Allocate output 
    -- START Gather input 
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
    local status = qc[subs.fn](in_ptr, nn_in_ptr, in_len, subs.width, 
      lkp, n_lkp, out_ptr, nn_out_ptr)
    assert(status == 0)
    invec:unget_chunk(l_chunk_num)
    l_chunk_num = l_chunk_num + 1
    return in_len, buf, nn_buf end
  local vargs = {}
  vargs.qtype = subs.out_qtype
  vargs.gen = gen
  vargs.has_nulls = subs.has_nulls
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return SC_to_lkp_C
