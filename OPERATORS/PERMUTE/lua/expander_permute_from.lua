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
  local subs, nn_subs = spfn(x, p, optargs)
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  --=== START handle nulls 
  local nn_func_name 
  if ( nn_subs ) then 
    assert(type(nn_subs) == "table")
    nn_func_name = assert(nn_subs.fn)
    qc.q_add(nn_subs)
  end 
  --=== STOP  handle nulls 
  local t_start = cutils.rdtsc()

  -- Now, get access to x's data and perform the operation
  assert(x:num_readers() == 0)
  local xcmem, nn_xcmem, n = x:get_lma_read()
  if ( nn_subs ) then 
    assert(type(nn_xcmem) == "CMEM")
    assert(nn_xcmem:is_foreign() == true)
  end 
  assert(n > 0)
  assert(x:num_readers() == 1)
  assert(xcmem:is_foreign() == true)
  local xptr = get_ptr(xcmem, subs.val_qtype)
  --=== START handle nulls 
  local nn_xptr
  if ( nn_subs ) then 
    nn_xptr = get_ptr(nn_xcmem, nn_subs.cast_as)
  end 
  --=== STOP  handle nulls 
  local l_chunk_num = 0 
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    local ybuf = cmem.new({
      size = subs.bufsz, qtype = subs.val_qtype, name = "permute_from"})
    ybuf:zero()
    ybuf:stealable(true)
    local yptr = get_ptr(ybuf, subs.val_qtype)
    --=== START handle nulls 
    local nn_ybuf, nn_yptr
    if ( nn_subs ) then 
      nn_ybuf = cmem.new({ size = nn_subs.bufsz, qtype = nn_subs.val_qtype})
      nn_ybuf:zero()
      nn_ybuf:stealable(true)
      nn_yptr = get_ptr(nn_ybuf, nn_subs.cast_as)
    end

    local plen, p_chunk = p:get_chunk(chunk_num) 
    if ( plen == 0 ) then 
      ybuf:delete() 
      nn_ybuf:delete() 
      -- release access to x 
      x:unget_lma_read()
      assert(x:num_readers() == 0)
      x:kill()
      return 0
    end
    local pptr = get_ptr(p_chunk, subs.cast_p_as)
    qc[func_name](xptr, pptr, plen, subs.num_elements, yptr)
    if ( nn_subs ) then 
      qc[nn_func_name](nn_xptr, pptr, plen, subs.num_elements, nn_yptr)
    end
    p:unget_chunk(chunk_num)
    if ( plen < subs.max_num_in_chunk ) then -- no more calls 
      -- release access to x
      x:unget_lma_read()
      assert(x:num_readers() == 0)
      x:kill()
    end
    l_chunk_num = l_chunk_num + 1 
    if ( nn_ybuf ) then
      nn_ybuf:nop()
    end
    return plen, ybuf, nn_ybuf
  end
  local vargs = {}
  vargs.qtype = subs.val_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  vargs.gen   = gen
  vargs.has_nulls = subs.has_nulls
  return lVector(vargs) 
  --======================================
end
return expander_permute_from
