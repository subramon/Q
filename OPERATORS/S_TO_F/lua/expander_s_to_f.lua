local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

return function (a, args)
  -- Get name of specializer function. By convention
  local sp_fn_name     = "Q/OPERATORS/S_TO_F/lua/" .. a .. "_specialize"
  local mem_init_name  = "Q/OPERATORS/S_TO_F/lua/" .. a .. "_mem_initialize"
  local mem_initialize = assert(require(mem_init_name), 
    "mem_initializer not found")
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
  local buff =  nil
  local l_chunk_num = 0
  local first_call = true
  local myvec
  
  local generator = function(chunk_num)
    -- Adding assert on l_chunk_num to have sync between 
    -- expected chunk_num and generator's l_chunk_num state
    assert(chunk_num == l_chunk_num)
    if ( first_call ) then
      first_call = false
      buff = assert(cmem.new(subs.buf_size, subs.out_qtype))
      myvec:no_memcpy(buff) -- hand control of this buff to the vector
    else
      myvec:flush_buffer()
    end
    local lb = chunk_size * l_chunk_num
    assert(lb < subs.len) -- Note not <=
    local num_elements = subs.len - lb
    if ( num_elements > chunk_size ) then num_elements = chunk_size end
    if ( num_elements <= 0 ) then return 0, nil end
    --=============================
    local casted_buff   = ffi.cast(cast_as,  get_ptr(buff))
    local start_time = qc.RDTSC()
    qc[func_name](casted_buff, chunk_size, subs.args, lb)
    record_time(start_time, func_name)
    return chunk_size, buff
  end
  myvec = lVector{gen=generator, has_nulls=false, qtype=out_qtype}
  return myvec
end
