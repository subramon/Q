  cidx = 0  -- chunk index
  repeat 
    ly = y:chunk(cidx)
    lz = z:chunk(cidx)
    cidx = cidx + 1
  until ( ly == 0 )
