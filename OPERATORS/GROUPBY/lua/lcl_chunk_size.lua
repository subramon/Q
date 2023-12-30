local function lcl_chunk_size(nb, optargs)
  --========================================
  -- default for max_num_in_chunk
  local y = math.floor(nb / 64)
  if ( ( y * 64 ) ~= nb ) then y = y + 1 end 
  local nC = y * 64
  -- over-ride max_num_in_chunk if needed
  if optargs then
    assert(type(optargs) == "table")
    if ( optargs.max_num_in_chunk ) then  
      local x = optargs.max_num_in_chunk
      assert(type(x) == "number")
      assert(x >= 64 )
      assert( (math.floor(x / 64 ) *64) == x)
      assert(nb <= x)
      nC  = x
    end
  end
  return nC
end
return lcl_chunk_size
