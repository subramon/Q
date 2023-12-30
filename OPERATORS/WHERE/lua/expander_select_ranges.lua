local ffi     = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function min(x, y)
  if ( x < y ) then return x else return y end
end

local function select_ranges(f1, lb, ub, optargs )
  --=================================
  local sp_fn_name = "Q/OPERATORS/WHERE/lua/select_ranges_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(f1, lb, ub, optargs ))
  assert(type(subs) == "table")
  --=================================
  --- preserve following across calls to gen()
  local start_idx = 1   -- must be outside function, in closure
  local stop_idx = #subs.lb_tbl -- must be outside function, in closure
  assert(start_idx <= stop_idx)
  local l_chunk_num = 0
  local stuff_left = true  -- indicates more to be consumed
  --=================================
  local function gen(chunk_num)
    -- print("SELECT Generating Output Chunk " .. chunk_num)
    assert(chunk_num == l_chunk_num)
    if ( stuff_left == false ) then return 0 end 
    local outbuf = cmem.new({size = subs.bufsz, qtype = subs.out_qtype})
    outbuf:zero()
    outbuf:stealable(true)
    local out_ptr = get_ptr(outbuf, subs.f2_cast_as)
    local out_len = 0 
    local nC = subs.max_num_in_chunk -- abbreviation
  
    local space_left = nC -- space in current chunk
    local new_start = start_idx
    while ( ( stuff_left ) and ( space_left > 0 ) ) do 
      for i = start_idx, stop_idx do 
        new_start = i
        local xlb = subs.lb_tbl[i]
        local xub = subs.ub_tbl[i]
        local num_in_range = xub - xlb 
        -- print("From Range " .. i .. ", consuming from " .. xlb .. " to " .. xub)
        -- this while loop iterates over input chunks
        -- If input chunk size == output chunk size, then this loop
        -- can execute at most twice. 
        while ( ( space_left > 0 ) and ( num_in_range > 0 ) ) do
          -- start consuming from (chunk_idx/chunk_pos)
          local chunk_idx = math.floor(xlb / nC)
          local chunk_pos = xlb % nC
          -- print(" start consuming from ", chunk_idx, chunk_pos)
          local num_in_chunk, chunk = f1:get_chunk(chunk_idx)
          assert(type(chunk) == "CMEM")
          local num_left_in_chunk = num_in_chunk - chunk_pos
          assert(num_left_in_chunk > 0)
          --  print("SELECT: Getting Input chunk " .. chunk_idx)
          -- amount to consume from this chunk is the smaller of 
          -- num_in_range and num_left_in_chunk, space_left
          local num_to_consume = 
            min(space_left, min(num_in_range, num_left_in_chunk))
          -- print(space_left, num_in_range, num_left_in_chunk)
          assert(num_to_consume > 0)
          -- print("Consuming " .. num_to_consume .. " from pos " .. chunk_pos)
          -- consume "num_to_consume" from chunk_idx starting at chunk_pos
          local in_ptr = get_ptr(chunk, subs.f1_cast_as)
          ffi.C.memcpy(out_ptr+out_len, in_ptr+chunk_pos, 
            num_to_consume * subs.width)
          f1:unget_chunk(chunk_idx)
          --============
          out_len = out_len + num_to_consume 
          space_left = space_left - num_to_consume
          -- print("Have " .. space_left .. " space in out buffer")
          num_in_range = num_in_range - num_to_consume
          xlb = xlb + num_to_consume 
          subs.lb_tbl[i] = xlb
        end -- end while 
      end
      if ( space_left > 0 ) then
        stuff_left = false
      end
    end
    l_chunk_num = l_chunk_num + 1
    start_idx = new_start --- set up for next call 
    if ( out_len == 0 ) then outbuf:delete(); return 0; end 
    return out_len, outbuf
  end
  --=================================
  local  vargs = {}
  vargs.gen = gen
  vargs.has_nulls = subs.has_nulls
  vargs.qtype = subs.out_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return select_ranges
