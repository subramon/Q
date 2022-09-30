local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/qcore'
local is_in   = require 'Q/UTILS/lua/is_in'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function lmin(x, y) if ( x < y ) then return x else return y end end

local function vshift(f1, shift_by, newval, optargs )
  --=================================
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/vshift_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(f1, shift_by, newval, optargs ))
  assert(type(subs) == "table")
  --=================================
  local chunk_idx = 0
  local nC = subs.max_num_in_chunk
  --=================================
  local f2_gen = function(chunk_num)
    -- sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    local f2_buf = assert(cmem.new(subs.bufsz))
    f2_buf:stealable(true)
    f2_buf:zero()
    local num_in_f2 = 0
    local cst_f2_buf = ffi.cast(subs.f2_cast_as, get_ptr(f2_buf))
    if ( shift_by > 0 ) then -- shift up 
      -- get nC - shift_by from this chunk 
      local f1_len, f1_buf = f1:get_chunk(chunk_idx)
      local m = lmin(nC, f1_len)
      local num_to_copy = m - shift_by
      if ( num_to_copy > 0 ) then
        local cst_f1_buf = ffi.cast(subs.f1_cast_as, get_ptr(f1_buf))
        local f1_offset = shift_by * subs.width
        local bytes_to_copy = num_to_copy * subs.width
        ffi.C.memcpy(cst_f2_buf, cst_f1_buf + f1_offset, bytes_to_copy)
        f1:unget_chunk(chunk_idx)
        num_in_f2 = num_in_f2 + num_to_copy
      end
      -- get "shift_by" from next  chunk
      if ( f1_len < nC ) then 
        -- no point looking any further
      else
        local f1_len, f1_buf = f1:get_chunk(chunk_idx+1)
        local num_to_copy = lmin(f1_len, shift_by)
        if ( num_to_copy > 0 ) then 
          local cst_f1_buf = ffi.cast(subs.f1_cast_as, get_ptr(f1_buf))
          local f2_offset = (nC-shift_by) * subs.width
          local bytes_to_copy = num_to_copy * subs.width
          ffi.C.memcpy(cst_f2_buf + f2_offset, cst_f1_buf, bytes_to_copy)
          num_in_f2 = num_in_f2 + num_to_copy
        end
        f1:unget_chunk(chunk_idx+1)
      end
    else -- shift down 
      error("TODO")
    end
    chunk_idx = chunk_idx + 1
    return num_in_f2, f2_buf
  end
  return lVector{gen=f2_gen, has_nulls=false, qtype=subs.out_qtype}
end
return require('Q/q_export').export('vshift', vshift)
