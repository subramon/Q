  function chk_chnks_lens_across_vecs(lens, chunks, n)
    -- chunks and lens should match up
    for k = 1, n do 
      if ( lens[k] >  0 ) then assert(chunks[k]) end 
      if ( lens[k] == 0 ) then assert(not chunks[k]) end 
    end
    -- chunks of all vectors should be of same length
    for k = 1, n do 
      assert(lens[k] == lens[1])
    end
    -- either you get all chunks or none 
    if ( chunks[1] ) then 
      for k = 2, n do assert(chunks[k]) end
    else
      for k = 2, n do assert(not chunks[k]) end
    end
    return lens[1]
  end
  return  chk_chnks_lens_across_vecs
