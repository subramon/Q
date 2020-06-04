local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local cVector  = require 'libvctr'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local chunk_size = cVector.chunk_size()
local function expander_numby(a, nb, optargs)
  -- Verification
  assert(type(a) == "lVector", "a must be a lVector ")
  if ( type(nb) == "Scalar") then nb = nb:to_num() end 
  assert(type(nb) == "number")
  assert( ( nb > 0) and ( nb < chunk_size) )
  local sp_fn_name = "Q/OPERATORS/GROUPBY/lua/numby_specialize"
  local spfn = assert(require(sp_fn_name))

  -- Keeping default is_safe value as true
  -- This will not allow C code to write values at incorrect locations
  local is_safe = true
  if optargs then
    assert(type(optargs) == "table")
    if ( optargs["is_safe"] == false ) then
      is_safe =  optargs["is_safe"]
      assert(type(is_safe) == "boolean")
    end
  end

  local status, subs = pcall(spfn, a:fldtype(), is_safe)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  local out_qtype = subs.out_qtype

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation

  assert(qc[func_name], "Symbol not defined " .. func_name)
  local sz_out = chunk_size -- note this is *NOT* nb or nb+1
  -- this is because when we allocate for a Vector, we allocate in chunks
  -- of a given size. This could be wasteful when nb << chunk_size
  -- Might want to reconsider the choice of Vector and consider
  -- a Reducer instead. TODO P3
  local sz_out_in_bytes = sz_out * qconsts.qtypes[out_qtype].width
  local out_buf = nil
  local first_call = true
  local chunk_idx = 0
  local in_ctype  = subs.in_ctype
  local out_ctype = subs.out_ctype
  local function numby_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      -- allocate buffer for output
      out_buf = assert(cmem.new(sz_out_in_bytes))
      out_buf:zero() -- particularly important for this operator
      first_call = false
    end
    while true do
      local a_len, a_chunk, a_nn_chunk = a:get_chunk(chunk_idx)
      if a_len == 0 then
        if chunk_idx == 0 then
          return 0, nil, nil
        else
          a:unget_chunk(chunk_idx)
          return nb, out_buf, nil
        end
      end
      assert(a_nn_chunk == nil, "Null is not supported")
    
      local casted_a_chunk = ffi.cast(in_ctype .. " *",  get_ptr(a_chunk))
      local casted_out_buf = ffi.cast(out_ctype .. "*",  get_ptr(out_buf))
      local start_time = qc.RDTSC()
      local status = qc[func_name](casted_a_chunk, a_len, casted_out_buf, nb, is_safe)
      record_time(start_time, func_name)
      assert(status == 0, "C error in NUMBY")
      if a_len < chunk_size then -- this is last chunk of a
        a:unget_chunk(chunk_idx)
        return nb, out_buf, nil
      end
      chunk_idx = chunk_idx + 1
    end
  end
  return lVector( { gen = numby_gen, has_nulls = false, qtype = out_qtype } )
end

return expander_numby
