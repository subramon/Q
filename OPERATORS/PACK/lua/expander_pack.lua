local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_pack(invecs, y, optargs)
  local specializer = "Q/OPERATORS/PACK/lua/pack_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(invecs, y, optargs))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  local l_chunk_num = 0
  local gen = function(chunk_num)
    local start_time = cutils.rdtsc()
    assert(chunk_num == l_chunk_num)
    local buf = assert(cmem.new(
      {size = subs.bufsz, qtype = subs.out_qtype}))
    buf:stealable(true)
    --=============================
    local widths  = assert(get_ptr(subs.width, "UI4"))
    local in_ptrs = assert(get_ptr(subs.cols, "char **"))
    local lens    = {}
    local chunks  = {}
    for k, v in ipairs(invecs) do 
      lens[k], chunks[k] = v:get_chunk(chunk_num)
      if ( chunks[k] ) then
        in_ptrs[k-1] = get_ptr(chunks[k], "char *")
      else
        in_ptrs[k-1] = ffi.NULL
      end
      assert(lens[k] == lens[1])
    end
    local out_len = lens[1]
    -- check for early exit 
    if ( out_len == 0 ) then 
      if ( subs.cols  ) then subs.cols:delete()  end 
      if ( subs.width ) then subs.width:delete() end 
      for k, v in ipairs(invecs) do v:kill() end
      return 0 
    end
    local out_ptr = get_ptr(buf, "char *")
    status = qc[func_name](in_ptrs, subs.n_vals, out_len, widths, out_ptr)
    assert(status == 0)
    record_time(start_time, func_name)
    for k, v in ipairs(invecs) do v:unget_chunk(l_chunk_num) end 
    if ( out_len < subs.max_num_in_chunk ) then 
      if ( subs.cols  ) then subs.cols:delete()  end 
      if ( subs.width ) then subs.width:delete() end 
      for k, v in ipairs(invecs) do v:kill() end
    end
    l_chunk_num = l_chunk_num + 1
    return out_len, buf, nn_buf
  end

  local vargs = {}
  vargs.gen   = gen
  vargs.qtype = subs.out_qtype
  vargs.has_nulls = false
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return expander_pack
