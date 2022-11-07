local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_permute(x, p, direction, optargs)
  local specializer = "Q/OPERATORS/PERMUTE/lua/permute_specialize"
  local spfn = assert(require(specializer))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  --=============================
  local t_start = cutils.rdtsc()
  assert(cutils.mk_file(subs.dir_name, subs.file_name, subs.file_sz))

  -- Create output vector y 
  local vargs = {}
  if ( optargs ) then 
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do 
      vargs[k] = v
    end
  end
  vargs.file_name = subs.dir_name .. "/" .. subs.file_name
  vargs.num_elements = subs.num_elements()
  vargs.qtype = subs.qtype
  vargs.width = subs.width
  vargs.memo_len = -1
  local y = lVector(vargs)
  --======================================
  -- Now, get access to y's data and perform the operation
  local ycmem = y:get_lma_write()
  assert(type(ycmem) == "CMEM")
  assert(ycmem:is_foreign() == true)
  local yptr = get_ptr(ycmem, subs.cast_y_as)

  local chunk_num = 0
  while ( true ) do
    local xlen, x_chunk, _ = x:get_chunk(chunk_num) 
    local plen, p_chunk, _ = p:get_chunk(chunk_num) 
    assert(xlen == plen)
    if ( xlen == 0 ) then break end 
    local xptr = get_ptr(x_chunk, subs.cast_x_as)
    local pptr = get_ptr(p_chunk, subs.cast_p_as)
    qc[func_name](xptr, pptr, xlen, yptr)
    chunk_num = chunk_num + 1 
  end
  -- Indicate write is over 
  y:unget_lma_write()
  record_time(t_start, "permute")
  return y
end
return expander_permute
