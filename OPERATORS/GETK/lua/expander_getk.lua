local qconsts = require 'Q/UTILS/lua/q_consts'
-- local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local record_time = require 'Q/UTILS/lua/record_time'

local function check_args(a, fval, k, optargs)
  assert(a)
  assert(type(a) == "string")
  assert( ( a == "mink" ) or ( a == "maxk" ) )

  assert(fval)
  assert(type(fval) == "lVector", "f1 must be a lVector")
  assert(fval:has_nulls() == false)

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
local function expander_getk(a, fval, k, optargs)
  -- validate input args
  check_args(a, fval, k, optargs)

  local sp_fn_name = "Q/OPERATORS/GETK/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs, tmpl = pcall(spfn, fval:qtype())
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local sort_fn = assert(subs.sort_fn)
  assert(qc[sort_fn], "Symbol not available" .. sort_fn)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)

  local is_ephemeral = false
  if ( optargs ) then
    if ( optargs.is_ephemeral == true ) then
      is_ephemeral = true
    end
  end

  local qtype = assert(subs.qtype)
  local ctype = assert(subs.ctype)
  local width = assert(subs.width)
  --=================================================
  local chunk_idx = 0
  local first_call = true
  local n = qconsts.chunk_size
  local nX, nZ
  local sort_buf_val, casted_sort_buf_val
  local bufX, casted_bufX
  local bufZ, casted_bufZ
  local num_in_Z, ptr_num_in_Z
  local len, chunk, nn_chunk, casted_chunk, nY
  -- TODO Consider case where there are less than k elements to return
  local function getk_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( first_call ) then
      -- create a buffer to sort each chunk as you get it
      sort_buf_val = cmem.new(n * width, qtype)
      sort_buf_val:zero() -- a precuation, not necessary
      casted_sort_buf_val = ffi.cast(ctype .. "*", get_ptr(sort_buf_val))

      -- create buffers for keeping topk from each chunk
      bufX = cmem.new(k * width, qtype)
      bufX:zero()
      casted_bufX = ffi.cast(ctype .. "*", get_ptr(bufX))
      nX = 0

      bufZ = cmem.new(k * width, qtype)
      bufZ:zero()
      casted_bufZ = ffi.cast(ctype .. "*", get_ptr(bufZ))
      nZ = k

      num_in_Z = cmem.new(4, "I4");
      ptr_num_in_Z = ffi.cast("uint32_t *",  get_ptr(num_in_Z))
    end

    while ( true ) do
      len, chunk, nn_chunk = fval:chunk(chunk_idx)
      if ( len == 0 ) then break end
      -- copy chunk into local buffer and sort it in right order
      casted_chunk = ffi.cast(ctype .. "*",  get_ptr(chunk))
      assert(qc[sort_fn], "function not found " .. sort_fn)
      sort_buf_val:zero()
      ffi.C.memcpy(casted_sort_buf_val, casted_chunk, len*width)
      local start_time = qc.RDTSC()
      qc[sort_fn](casted_sort_buf_val, len)
      record_time(start_time, sort_fn)
      --================================
      if ( k < len ) then nY = k else nY = len end
      if ( chunk_idx == 0 )  then
        ffi.C.memcpy(casted_bufX, casted_sort_buf_val, nY*width)
        nX = nY
      else
        start_time = qc.RDTSC()
        qc[func](casted_bufX, nX, casted_sort_buf_val, nY, casted_bufZ, nZ, ptr_num_in_Z)
        record_time(start_time, func)
        -- copy from bufZ to bufX
        local num_in_Z = ptr_num_in_Z[0]
        ffi.C.memcpy(casted_bufX, casted_bufZ, num_in_Z*width)
        nX = num_in_Z
      end
      chunk_idx = chunk_idx + 1
    end
    return nX, bufX, nil
  end
  return lVector( { gen = getk_gen, qtype = qtype, has_nulls = false } ) 
end
return expander_getk
