local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/qcore'
local is_in   = require 'Q/UTILS/lua/is_in'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function lmin(x, y) if ( x < y ) then return x else return y end 

local function vshift(f1, shift_by, newval, optargs )
  --=================================
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/vshift_specialize"
  local spfn = assert(require(sp_fn_name))
  if not status then print(subs) end
  assert(status, "Specializer " .. sp_fn_name .. " failed")
  local func_name = assert(subs.fn)
  --=================================
  local chunk_idx = 0
  --============================================
  assert(shift_by > 0) -- TODO P1 Fix this limitation, 
  local first_call = true
  local f2_gen = function(chunk_num)
    -- sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    local f2_buf = assert(cmem.new(subs.bufsz))
    f2_buf:stealable(true)
    f2_buf:zero()
    cst_f2_buf = ffi.cast(subs.f2_cast_as, get_ptr(f2_buf))
    local f2_to_write = subs.max_num_in_chunk 
    -- f2_to_write = how much of f2_buf is *LEFT* for writing
    local f2_written = 0 
    local next_f1_len = 0; 
    local next_f1_buf; local cst_next_f1_buf = ffi.NULL
    local f1_len, f1_buf = f1:get_chunk(chunk_idx)
    local f1_to_read = f1_len -- how much of f1_buf is *LEFT* to read 
    local f1_read = 0 
    -- If no more input, flush f2_buf and return 
    if f1_len == 0 then 
      -- flush f2_buf TODO
      return f2_len, f2_buf
    end
    --===================================================
      -- copy min(shift_by, f1_len) into f2_buf with following exception
      if ( first_call ) then
        -- first buffer, dump those values
      else
        -- find smaller of f2_to_write and f1_to_read
        local n = lmin(f2_to_write, f1_to_read)
        ffi.C.memcpy(
          cst_f2_buf + (n * subs.width),
          cst_f1_buf + (n * subs.width), n * subs.width)
        f2_written  = f2_written  + n
        f1_read     = f1_read     + n
        f2_to_write = f2_to_write - n
        f1_to_read  = f1_to_read  - n
      end
        
      local next_f1_len, next_f1_buf = f1:get_chunk(chunk_idx+1)
      if ( next_f1_buf ) then 
       local cst_next_f1_buf = ffi.cast(subs.f1_cast_as, get_ptr(next_f1_buf))
      end
      local cst_f1_buf = ffi.cast(subs.f1_cast_as, get_ptr(f1_buf))
      --===============
      local start_time = cutils.rdtsc()
      qc[func_name](cst_f1_buf, f1_len, cst_next_f1_buf, next_f1_len, 
        cst_f2_buf, cst_new_val)
      record_time(start_time, func_name)
      f1:unget_chunk(chunk_idx)
    end
    first_call = false
    chunk_idx = chunk_idx + 1
    return f1_len, f2_buf
  end
  return lVector{gen=f2_gen, has_nulls=false, qtype=subs.out_qtype}
end
return require('Q/q_export').export('vshift', vshift)
