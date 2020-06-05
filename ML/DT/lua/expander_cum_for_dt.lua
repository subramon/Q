local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local cVector  = require 'libvctr'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_cum_for_dt(f, g, ng)
  -- f is the data vector
  -- g is the goal vector
  -- ng is the number of values goal can take on
  -- Note: It is implicit that the goal values are 0, 1, ... (ng-1)
  -- Verification
  assert(type(f) == "lVector", "f must be a lVector ")
  assert(type(g) == "lVector", "g must be a lVector ")
  assert(not a:has_nulls())
  assert(not b:has_nulls())
  -- TODO P3: Check that f is sorted ascending
  if ( ( a:is_eov() ) and ( b:is_eov() ) ) then 
    assert(a:length() == b:length(), "size of a and b is not same")
  end

  --=======================
  local sp_fn_name = "Q/ML/DT/lua/cum_for_dt/cum_for_dt_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, f:qtype(), g:qtype())
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
  -- Note implicit assumption that number of elements for a specific 
  -- data value will be no more than 2^32
  --=================================
  local cst_f_as = subs.f_type .. " * "
  local cst_g_as = subs.g_type .. " * "
  --=================================
  local chunk_size = cVector.chunk_size()

  local val_qtype = subs.v_qtype
  local val_buf = cmem.new(0)
  local val_buf_sz = chunk_size * subs.v_width
  local cst_val_as = subs.v_ctype .. "*"

  local cnt_qtype = subs.c_qtype
  local cnts_buf = {}
  for i = 1, ng do 
    cnts_buf[i] = cmem.new(0) 
  end
  local cnt_buf_sz = chunk_size * subs.c_width
  local cst_cnt_as = subs.c_ctype .. "*"
  --========================
  local a_chunk_idx = 0
  local l_chunk_num = 0
  -- n_out counts number of entries in output buffer
  local x_n_out = cmem.new(ffi.sizeof("uint64_t"))
  local n_out = get_ptr(x_n_out, "I8")
  n_out[0] = 0 
  -- aidx counts how much of input buffer we have consumed
  -- useful because we may have consumed half of it and have
  -- to return because output bufer is full. When we come back
  -- we need to know where we left off
  local x_aidx = cmem.new(ffi.sizeof("uint64_t"))
  local aidx = get_ptr(x_aidx, "I8")
  aidx[0] = 0 
  
  local function cum_for_dt_gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    if ( not out_buf:is_data() ) then 
      out_buf = assert(cmem.new({size = val_buf_sz, qtype = val_qtype}))
      out_buf:stealable(true)
      for i = 1, ng do 
        cnts_buf[i] = assert(cmem.new({size = cnts_buf_sz,
          qtype = cnts_qtype}))
        cnts_buf[i]:stealable(true)
      end
    end
    repeat
      local f_len, f_chunk = f:get_chunk(l_chunk_num)
      local g_len, g_chunk = g:get_chunk(l_chunk_num)
      if ( a_len == 0 ) then -- no more input, return whatever is in out
        return tonumber(n_out[0]), out_buf
      end
      assert(f_len == g_len)
      local cst_f_chunk  = ffi.cast(cst_f_as,   get_ptr(f_chunk))
      local cst_g_chunk  = ffi.cast(cst_g_as,   get_ptr(g_chunk))
      local cst_val_buf  = ffi.cast(cst_val_as, get_ptr(val_buf))
      local cst_cnts_buf = XXXXXXX TODO
      local start_time = qc.RDTSC()
      local status = qc[func_name](cst_f_chunk, cst_g_chunk, ng, aidx, 
        a_len, cst_val_buf, cst_cnts_buf, sz_out, n_out)
      assert(status == 0)
      record_time(start_time, func_name)
      -- if you have consumed all you got from the a_chunk,
      -- then you need to move to the next chunk
      if ( tonumber(aidx[0]) == a_len ) then
        f:unget_chunk(l_chunk_num)
        g:unget_chunk(l_chunk_num)
        l_chunk_num = l_chunk_num + 1
        aidx[0] = 0
      end
    until ( tonumber(n_out[0]) == sz_out )
    return tonumber(n_out[0]), out_buf
  end
  return lVector( { gen = cum_for_dt_gen, has_nulls = false, qtype = a:qtype() } )
end
return expander_where
