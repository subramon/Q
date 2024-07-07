local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function lmin(x, y) if x < y then return x else return y end end 

-- TODO P3 Optimize by moving to C implementation 
--
local function repeater(f1, f2, optargs )
  -- f1 is the Vector whose values are to be repeated
  -- f2 tells us how many times to repeat the value
  local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/repeat_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(f1, f2, optargs))

  local in_idx        = -1 -- will be incremented before being used
  local l_chunk_num   = 0
  local num_to_repeat = 0
  -- num_in_out + space_in_out == subs.max_num_in_chunk 
  local f3_gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local buf = assert(cmem.new({size = subs.bufsz, qtype = subs.f3_qtype}))
    buf:stealable(true)
    local space_in_out = subs.max_num_in_chunk
    local num_in_out = 0
    --=============================
    for i = 1, math.huge do  -- infinite loop broken inside 
      local f1_val, f2_val
      if ( num_to_repeat == 0 ) then 
        in_idx = in_idx + 1 
        f2_val = f2:get1(in_idx); 
        if ( type(f2_val) == "Scalar") then 
          num_to_repeat = f2_val:to_num()
        end 
      end

      f1_val = f1:get1(in_idx); 
      if ( f1_val == nil ) then 
        assert(f2_val == nil)
        return num_in_out, buf
      end 
      assert(type(f1_val) == "Scalar")
      assert(num_to_repeat >= 0)
      local n = lmin(num_to_repeat, space_in_out)
      if ( n > 0 ) then 
        num_to_repeat = num_to_repeat - n
        space_in_out  = space_in_out - n
        --=============================
        local cbuf = assert(get_ptr(buf, subs.cast_f3_as))
        local out_val = f1_val:to_data()
        for i = 1, n do 
          ffi.C.memcpy(cbuf+(num_in_out + i -1), out_val, subs.f3_width)
        end
        num_in_out = num_in_out + n 
        if ( space_in_out  == 0 ) then 
          l_chunk_num = l_chunk_num + 1
          return num_in_out, buf 
        end
      end
    end
  end
  local vargs = {}
  if ( optargs ) then 
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do vargs[k] = v end
  end
  vargs.gen       = f3_gen
  vargs.qtype     = subs.f3_qtype
  vargs.has_nulls = false 
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return require('Q/q_export').export('repeater', repeater)
