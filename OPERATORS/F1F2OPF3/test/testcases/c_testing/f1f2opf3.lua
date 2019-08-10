local ffi = require 'ffi'
local g_err = require 'Q/UTILS/lua/error_code'
local qc = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

-- allocate chunk and prepare convertor function for calling C apis 
 local get_chunk = function(qtype_input1, qtype_input2, operation, qtype_fn, input1)
  local chunk
  local convertor
  local length = #input1
  if qtype_fn then
    local qtype = qtype_fn(qtype_input1, qtype_input2)

    local length_in_bytes = qconsts.qtypes[qtype].width * length
    chunk = assert(get_ptr(cmem.new(length_in_bytes), qtype), g_err.FFI_MALLOC_ERROR)

    --chunk = assert(ffi.new(qconsts.qtypes[qtype].ctype .. "[?]", length), g_err.FFI_NEW_ERROR)
    convertor = operation .. "_" .. qtype_input1 .. "_" .. qtype_input2 .. "_" .. qtype
  else
    local input_length = math.floor(length / qconsts.chunk_size)
    if ((input_length * qconsts.chunk_size ) ~= length) then length = input_length + 1 end
    --print("length = " ,length)

    local length_in_bytes = 8 * length
    chunk = assert(get_ptr(cmem.new(length_in_bytes)), g_err.FFI_MALLOC_ERROR)
    chunk = ffi.cast("uint64_t*", chunk)

    --chunk = assert(ffi.new("uint64_t[?]", length), g_err.FFI_NEW_ERROR)
    convertor = operation .. "_" .. qtype_input1 .. "_" .. qtype_input2
  end
  return chunk, length, convertor
end

 
-- Thin wrapper function on the top of C function ( vvadd_I1_I1_I1.c ) 
-- input args are in the order below
-- operation like vvadd, vvsub etc
-- qtype_input1 - qtype of first input argument
-- qtype_input2 - qtype of second input argument
-- input1 - lua table of values
-- input2 - lua table of values
-- qtype - qtype of output result



return function(operation, qtype_input1, qtype_input2, input1, input2, qtype_fn)
  local chunk1 = assert(get_ptr(cmem.new(qconsts.qtypes[qtype_input1].width * #input1)), g_err.FFI_MALLOC_ERROR)
  chunk1 = ffi.cast(qconsts.qtypes[qtype_input1].ctype.. "*", chunk1)
  for i=0, #input1 - 1 do
    chunk1[i] = input1[i+1]
  end

  local chunk2 = assert(get_ptr(cmem.new(qconsts.qtypes[qtype_input2].width * #input2)), g_err.FFI_MALLOC_ERROR)
  chunk2 = ffi.cast(qconsts.qtypes[qtype_input2].ctype.. "*", chunk2)
  for i=0, #input2 - 1 do
    chunk2[i] = input2[i+1]
  end

--  local chunk1 = assert(ffi.new(qconsts.qtypes[qtype_input1].ctype .. "[?]", #input1, input1), g_err.FFI_NEW_ERROR)
--  local chunk2 = assert(ffi.new(qconsts.qtypes[qtype_input2].ctype .. "[?]", #input2, input2), g_err.FFI_NEW_ERROR)
  
  local chunk, length, convertor = get_chunk(qtype_input1, qtype_input2, operation, qtype_fn, input1)
  
  -- convertor will be of the format -- e.g. - vvadd_I1_I1_I1
  --print(convertor)
  local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/" .. operation .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, qtype_input1, qtype_input2)

  if ( not qc[convertor] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  assert(qc[convertor], g_err.CONVERTOR_FUNCTION_NULL)
  qc[convertor](chunk1, chunk2, #input1, chunk)
  local ret = {}
  for i=1, length do
    table.insert(ret,chunk[i-1])
    --print(chunk[i-1])
  end
  return ret
end
