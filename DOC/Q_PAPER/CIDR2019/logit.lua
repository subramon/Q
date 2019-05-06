local function logit(v)
  -- determine type of input 
  local qtype = v:fldtype()
  local ctype = qconsts.qtypes[qtype].ctype
  local n     = qconsts.chunk_size
  local w     = qconsts.qtypes[qtype].width
  local d2    = get_ptr(cmem.new(n*w, qtype))
  local v2    = lVector({gen = true, qtype = qtype})
  local cidx = 0 -- chunk index
  while true do 
    local n1, d1 = v:chunk(cidx)
    -- quit when no more input
    if ( n1 == 0 ) then break end 
    -- access data of input
    local cd1 = ffi.cast(ctype .. "*", get_ptr(d1)) 
    -- core operation is as follows
    for i = 0, n1 do 
      cd2[i] = 1.0 / (1.0 + math.exp(-1 * cd1[i]))
    end
    -- pass buffer to output vector
    v2:put_chunk(d2, nil, n1) 
    -- start work on next chunk
    cidx = cidx + 1 
  end
  v2:eov() -- no more data
  return v2
end
return logit
