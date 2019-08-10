local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local ffi = require 'ffi'
local record_time = require 'Q/UTILS/lua/record_time'
local Reducer	  = require 'Q/RUNTIME/lua/Reducer'

local function check_args(a, val, drag, k, optargs)
  assert(a)
  assert(type(a) == "string")
  assert( ( a == "mink" ) or ( a == "maxk" ) )

  assert(val)
  assert(type(val) == "lVector", "val must be a lVector")
  assert(val:has_nulls() == false)

  assert(drag)
  assert(type(drag) == "lVector", "drag must be a lVector")
  assert(drag:has_nulls() == false)

  -- Here is a case where it makes sense for k to be a number
  -- and NOT a Scalar
  assert(k)
  assert(type(k) == "number")
  -- decided to have k less than 128
  assert( (k > 0 ) and ( k < 128 ) )

  if ( optargs ) then
    assert(type(optargs) == "table")
  end
  -- optargs is a palce holder for now
  return true
end

-- This operator produces 1 vector
local function expander_getk_reducer(a, val, drag, k, optargs)
  -- validate input args
  check_args(a, val, drag, k, optargs)

  local sp_fn_name = "Q/OPERATORS/GETK/lua/" .. a .. "_specialize_reducer"
  local mem_init_name = "Q/OPERATORS/GETK/lua/" .. a .. "_mem_initialize_reducer"
  local spfn = assert(require(sp_fn_name))
  local mem_initialize = assert(require(mem_init_name), "mem_initializer not found")

  local status, subs = pcall(spfn, val:qtype(), drag:qtype())
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func], "Symbol not available" .. func)

  -- calling mem_initializer
  subs.k = k
  subs.a = a  
  local reduce_struct, cst_as, getter = mem_initialize(subs)
  assert(reduce_struct)
  assert(getter)
  assert(type(getter) == "function")

  local v_qtype = assert(subs.v_qtype)
  local v_ctype = assert(subs.v_ctype)
  local v_width = assert(subs.v_width)

  local d_qtype = assert(subs.d_qtype)
  local d_ctype = assert(subs.d_ctype)
  local d_width = assert(subs.d_width)
  --=================================================
  local chunk_idx = 0

  -- TODO Consider case where there are less than k elements to return
  local function getk_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    val_len, val_chunk, val_nn_chunk = val:chunk(chunk_idx)
    drag_len, drag_chunk, drag_nn_chunk = drag:chunk(chunk_idx)
    if val_len and val_len > 0 then
      local cst_val_chunk = ffi.cast(v_ctype .. "*",  get_ptr(val_chunk))
      local cst_drag_chunk = ffi.cast(d_ctype .. "*",  get_ptr(drag_chunk))
      local cst_reduce_struct = ffi.cast(cst_as, get_ptr(reduce_struct))
      local start_time = qc.RDTSC()
      qc[func](cst_val_chunk, val_len, cst_drag_chunk, cst_reduce_struct)
      record_time(start_time, func)
      chunk_idx = chunk_idx + 1
    else
      return nil
    end
    return reduce_struct
  end
  return Reducer ( { gen = getk_gen, func = getter, value = reduce_struct} )
end
return expander_getk_reducer
