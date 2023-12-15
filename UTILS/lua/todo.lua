local function min(x, y) 
  if ( x < y ) then return x else return y end 
end

local start_idx = 0   -- must be outside function, in closure
local  stop_idx = #lb -- must be outside function, in closure
local function gen()
  -- abbreviations 
  local lb = subs.lb
  local ub = subs.ub
  local nC = subs.max_num_in_chunk

  local space_left = nC -- space in current chunk
  local stuff_left = true  -- do ranges indicate more to create?
  local new_start = start_idx
  while ( ( stuff_left ) and ( space_left > 0 ) ) do 
    for i = start_idx, stop_idx do 
      new_start = i
      local xlb = lb[i]
      local xub = ub[i]
      local num_in_range = xub - xlb 
      -- this while loop iterates over input chunks
      -- If input chunk size == output chunk size, then this loop
      -- can execute at most twice. 
      while ( ( space_left > 0 ) and ( num_in_range > 0 ) ) do
        -- start consuming from (chunk_idx/chunk_pos)
        local chunk_idx = xlb / nC
        local chunk_pos = xlb % nC
        local num_in_chunk, chunk = invec:get_chunk(chunk_idx)
        assert(type(chunk) == "CMEM")
        local num_left_in_chunk = num_in_chunk - chunk_idx
        assert(num_left_in_chunk > 0)
        -- amount to consume from this chunk is the smaller of 
        -- num_in_range and num_left_in_chunk, space_left
        local num_to_consume = 
          min(space_left, min(num_in_range, num_left_in_chunk))
        assert(num_to_consume > 0)
        -- consume "num_to_consume" from chunk_idx starting at chunk_pos
        space_left = space_left - num_to_consume
        num_in_range = num_in_range - num_to_consume
        xlb = xlb + num_to_consume 
        lb[i] = xlb
      end -- end while 
    end
  end
  start_idx = new_start
end
