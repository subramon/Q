local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local cVector  = require 'libvctr'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_where(a, b)
  -- Verification
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(type(b) == "lVector", "b must be a lVector ")
  assert(b:qtype() == "B1", "b must be of type B1")
  assert(not a:has_nulls())
  assert(not b:has_nulls())
  if ( ( a:is_eov() ) and ( b:is_eov() ) ) then 
    assert(a:length() == b:length(), "size of a and b is not same")
  end
  local sp_fn_name = "Q/OPERATORS/WHERE/lua/where_specialize"
  local spfn = assert(require(sp_fn_name))

  -- Check min and max value from bit vector metadata
  -- TODO P3 Write a test for case of pre-computed
  local bmeta = b:meta()
  if bmeta.aux and bmeta.aux["min"] and bmeta.aux["max"] then
    if bmeta.aux["min"] == 1 and bmeta.aux["max"] == 1 then
      return a
    elseif bmeta.aux["min"] == 0 and bmeta.aux["max"] == 0 then
      return nil
    end
  end

  local status, subs = pcall(spfn, a:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  --================================
  local out_buf = cmem.new(0)
  local a_chunk_idx = 0
  local chunk_size = cVector.chunk_size()
  local sz_out = chunk_size * qconsts.qtypes[a:qtype()].width
  local l_chunk_num = 0
  local cst_a_as   = qconsts.qtypes[a:fldtype()].ctype .. "*"
  local cst_b_as   = "uint64_t *" -- this is a bit vector 
  -- n_out counts number of entries in output buffer
  local x_n_out = cmem.new(ffi.sizeof("uint64_t"))
  local n_out = get_ptr(x_n_out, "I8")
  n_out[0] = 0 -- TODO Where should this be?
  -- aidx counts how much of input buffer we have consumed
  -- useful because we may have consumed half of it and have
  -- to return because output bufer is full. When we come back
  -- we need to know where we left off
  local x_aidx = cmem.new(ffi.sizeof("uint64_t"))
  local aidx = get_ptr(x_aidx, "I8")
  aidx[0] = 0 -- TODO Where should this be?
  
  local function where_gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    if ( not out_buf:is_data() ) then 
      out_buf = assert(cmem.new( { size = sz_out, qtype = a:qtype()}))
      out_buf:stealable(true)
    end
    repeat
      local a_len, a_chunk, a_nn_chunk = a:get_chunk(l_chunk_num)
      local b_len, b_chunk, b_nn_chunk = b:get_chunk(l_chunk_num)
      if ( a_len == 0 ) then -- no more input, return whatever is in out
        return tonumber(n_out[0]), out_buf
      end
      assert(a_len == b_len)
      local cst_a_chunk = ffi.cast(cst_a_as, get_ptr(a_chunk))
      local cst_b_chunk = ffi.cast(cst_b_as, get_ptr(b_chunk))
      local cst_out_buf = ffi.cast(cst_a_as, get_ptr(out_buf))
      local start_time = qc.RDTSC()
      local status = qc[func_name](cst_a_chunk, cst_b_chunk, aidx, 
        a_len, cst_out_buf, sz_out, n_out)
      assert(status == 0)
      record_time(start_time, func_name)
      -- if you have consumed all you got from the a_chunk,
      -- then you need to move to the next chunk
      if ( tonumber(aidx[0]) == a_len ) then
        a:unget_chunk(l_chunk_num)
        b:unget_chunk(l_chunk_num)
        l_chunk_num = l_chunk_num + 1
        aidx[0] = 0
      end
    until ( tonumber(n_out[0]) == sz_out )
    return tonumber(n_out[0]), out_buf
  end
  return lVector( { gen = where_gen, has_nulls = false, qtype = a:qtype() } )
end
return expander_where
