local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_sort1(x, sort_order, optargs)
  local specializer = "Q/OPERATORS/SORT1/lua/sort1_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(x, sort_order))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  -- Check is already sorted correct way and don't repeat
  local curr_sort_order = x:get_meta("sort_order")
  if ( subs.sort_order == curr_sort_order ) then return x end 
  --=============================
  local t_start = cutils.rdtsc()
  assert(x:chunks_to_lma())
  local file_name, file_sz = x:make_lma()
  assert(type(file_name) == "string"); assert(#file_name > 0)
  assert(type(file_sz) == "number");   assert(file_sz    > 0)

  local qtype = x:qtype()
  local width = x:width()
  local nx = math.floor(file_sz / width)
  assert(nx == math.ceil(file_sz / width))
  assert(nx == x:num_elements())

  -- Create output vector y 
  local vargs = {}
  if ( optargs ) then 
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do 
      vargs[k] = v
    end
  end
  vargs.file_name = file_name
  vargs.num_elements = nx
  vargs.qtype = qtype
  vargs.width = width
  vargs.memo_len = -1
  local y = lVector(vargs)
  y:set_meta("sort_order", subs.sort_order)
  --======================================
  -- Now, get access to y's data and perform the operation
  local ycmem = y:get_lma_write()
  assert(type(ycmem) == "CMEM")
  assert(ycmem:is_foreign() == true)
  local yptr = get_ptr(ycmem, subs.cast_y_as)

  qc[func_name](yptr, nx)
  -- Above is an unusual function: returns void instead of int status 

  -- Indicate write is over 
  y:unget_lma_write()
  assert(y:num_readers() == 0)
  record_time(t_start, "sort1")
  return y
end
return expander_sort1
