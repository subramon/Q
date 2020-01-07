local ffi      = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function expander_indices(op, a)
  -- Verification
  assert(op == "indices")
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(a:qtype() == "B1", "a must be of type B1")
  -- Condition is good but we do not know enough to evaluate it 
  -- at this stage since vectors coyld be in nascent state
  -- assert(a:length() == b:length(), "size of a and b is not same")
  local sp_fn_name = "Q/OPERATORS/INDEX/lua/indices_specialize"
  local spfn = assert(require(sp_fn_name))
  
  local status, subs = pcall(spfn, a:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic Compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  local sz_out          = qconsts.chunk_size 
  local sz_out_in_bytes = sz_out * qconsts.qtypes['I8'].width
  local out_buf = nil
  local first_call = true
  local n_out = nil
  local aidx  = nil
  local a_chunk_idx = 0
  
  local function indices_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    --assert(chunk_num == a_chunk_idx)
    if ( first_call ) then 
      -- allocate buffer for output
      out_buf = assert(cmem.new(sz_out_in_bytes))

      n_out = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      n_out = ffi.cast("uint64_t *", n_out)

      aidx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      aidx = ffi.cast("uint64_t *", aidx)
      aidx[0] = 0
      
      first_call = false
    end
    
    -- Initialize to zero
    n_out[0] = 0
    
    repeat
      local a_len, a_chunk, a_nn_chunk = a:chunk(a_chunk_idx)
      if a_len == 0 then 
        -- print("returned")
        -- print("$$$$$",tonumber(n_out[0]))
        return tonumber(n_out[0]), out_buf, nil 
      end
      -- assert(a_len == b_len)
      assert(a_nn_chunk == nil, "Indices vector cannot have nulls")
      
      -- vec_pos indicates how many elements of vector we have consumed
      local vec_pos = a_chunk_idx * qconsts.chunk_size
      local casted_a_chunk = ffi.cast( qconsts.qtypes[a:fldtype()].ctype .. "*",  get_ptr(a_chunk))
      local casted_out_buf = ffi.cast( qconsts.qtypes["I8"].ctype .. "*",  get_ptr(out_buf))
      -- print(casted_a_chunk, aidx, a_len, casted_out_buf, sz_out, n_out)
      local status = qc[func_name](casted_a_chunk, aidx, a_len, casted_out_buf, sz_out, n_out, vec_pos)
      -- print("\n=================")
      -- print(aidx[0])
      assert(status == 0, "C error in INDICES")
      if ( tonumber(aidx[0]) == a_len ) then
        a_chunk_idx = a_chunk_idx + 1
        aidx[0] = 0
      end
    until ( tonumber(n_out[0]) == sz_out )
    -- print("$$$$$",tonumber(n_out[0]))
    -- print(out_buf[0])
    return tonumber(n_out[0]), out_buf, nil
  end
  return lVector( { gen = indices_gen, has_nulls = false, qtype = "I8" } )
end

return expander_indices
