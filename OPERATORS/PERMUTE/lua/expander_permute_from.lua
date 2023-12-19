local ffi      = require 'ffi'
local cutils   = require 'libcutils'
local cmem     = require 'libcmem'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_permute_from(x, p, optargs)
  local specializer = "Q/OPERATORS/PERMUTE/lua/permute_from_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(x, p, optargs))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  --=============================
  local t_start = cutils.rdtsc()

  -- Now, get access to x's data and perform the operation
  assert(x:num_readers() == 0)
  local xcmem = x:get_lma_read()
  assert(x:num_readers() == 1)
  assert(xcmem:is_foreign() == true)
  local xptr = get_ptr(xcmem)
  xptr = ffi.cast(subs.cast_x_as, xptr)
  --===========================
  local l_chunk_num = 0 
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    local ybuf = cmem.new({
      size = subs.bufsz, qtype = subs.val_qtype, name = "permute_from"})
    ybuf:stealable(true)
    local plen, p_chunk = p:get_chunk(chunk_num) 
    if ( plen == 0 ) then 
      ybuf:delete() 
      x:unget_lma_read()
      assert(x:num_readers() == 0)
      x:kill()
      return 0
    end
    local pptr = get_ptr(p_chunk, subs.cast_p_as)
    local yptr = get_ptr(ybuf, subs.cast_y_as)
    qc[func_name](xptr, pptr, plen, subs.num_elements, yptr)
    p:unget_chunk(chunk_num)
    if ( plen < subs.max_num_in_chunk ) then -- no more calls 
      x:unget_lma_read()
      assert(x:num_readers() == 0)
      x:kill()
    end
    l_chunk_num = l_chunk_num + 1 
    return plen, ybuf
  end
  local vargs = {}
  vargs.qtype = subs.val_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  vargs.gen   = gen
  vargs.has_nulls = false
  return lVector(vargs) 
  --======================================
end
return expander_permute_from
