local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/qcore'
local is_in   = require 'Q/UTILS/lua/is_in'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function lmin(x, y) if ( x < y ) then return x else return y end end

local function select_ranges(f1, lb, ub, optargs )
  --=================================
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/select_ranges_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(f1, lb, ub, optargs ))
  assert(type(subs) == "table")
  --=================================
  local nC = subs.max_num_in_chunk -- alias 
  --- preserve across calls to f2_gen()
  local chunk_idx = 0
  local lbnum = lb:num_elements() -- number of ranges
  local lbidx = 0 -- which range to read from 
  local lboff = 0 -- how many elements of range lbidx have been consumed
  --=================================
  local f2_gen = function(chunk_num)
    -- sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    local f2_buf = assert(cmem.new(subs.bufsz))
    f2_buf:stealable(true)
    f2_buf:zero()
    local cst_f2_buf = ffi.cast(subs.f2_cast_as, get_ptr(f2_buf))
    local num_in_f2 = 0
    local space_in_f2 = nC

    while ( true ) do
      if ( lbidx >= lbnum ) then break end -- no more input 
      local ilb = lb:get1(lbidx):to_num()
      local iub = ub:get1(lbidx):to_num()
      assert(ilb < iub)
      ilb = ilb + lboff 
      -- TODO reduce iub if too large 
      assert(ilb < iub)
      local f1_chunk_idx = math.floor(ilb / nC)
      local f1_chunk_off = floor(ilb % nC)
      local num_in_f1 = nC - f1_chunk_off
      local num_to_copy = lmin(space_in_f2, num_in_f1)
      -- copy 
      lboff = lboff + num_to_copy
      space_in_f2 = space_in_f2 - num_to_copy
      if ( lboff or ilb == iub ) then
        lbidx = lbidx + 1 -- move on to next range 
      end
      if ( space_in_f2 == 0 ) then 
        break
      end
    end
    chunk_idx = chunk_idx + 1
    return num_in_f2, f2_buf
  end
  return lVector{gen=f2_gen, has_nulls=false, qtype=subs.out_qtype,
    max_num_in_chunk = subs.max_num_in_chunk}
end
return require('Q/q_export').export('select_ranges', select_ranges)
