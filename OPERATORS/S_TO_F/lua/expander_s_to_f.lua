local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cmem    = require 'libcmem'
local cVector = require 'libvctr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local csz     = cVector.chunk_size()

return function (a, args)
  -- Get name of specializer function. By convention
  local sp_fn_name     = "Q/OPERATORS/S_TO_F/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name), "Specializer not found")
  local status, subs = pcall(spfn, args)
  if ( not status ) then print(sp_fn_name, subs) end 
  assert(status, "Specializer failed ")
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Function not found " .. func_name)

  local cast_as = subs.out_ctype .. "*"
  local buf =  nil
  local l_chunk_num = 0
  local first_call = true
  -- TODO Avoid the memcpy that the put  chunk would cause
  
  local generator = function(chunk_num)
    -- Adding assert on l_chunk_num to have sync between 
    -- expected chunk_num and generator's l_chunk_num state
    assert(chunk_num == l_chunk_num)
    if ( first_call ) then
      first_call = false
      buf = assert(cmem.new(subs.buf_size, subs.out_qtype))
    end
    --=============================
    local lb = csz * l_chunk_num
    assert(lb < subs.len) -- Note not <=
    local num_elements = subs.len - lb
    if ( num_elements > csz ) then 
      num_elements = csz 
    end
    if ( num_elements <= 0 ) then return 0, nil end
    --=============================
    local cbuf   = ffi.cast(cast_as, get_ptr(buf))
    local start_time = qc.RDTSC()
    qc[func_name](cbuf, num_elements, subs.args, lb)
    record_time(start_time, func_name)
    l_chunk_num = l_chunk_num + 1 
    return num_elements, buf
  end
  return lVector{gen = generator, qtype = subs.out_qtype}
end
