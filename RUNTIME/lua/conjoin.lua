local Vector		= require 'libvec'
--====================================
--
local function conjoin(vecs)
  assert(vecs)
  assert(type(vecs) == "table")
  for _, v in pairs(vecs) do 
    assert(type(v) == "lVector")
  end
  for k1, v1 in pairs(vecs) do 
    for k2, v2 in pairs(vecs) do 
      if ( k1 ~= k2 ) then  
        v1:set_sibling(v2)
      end
    end
  end
end
return conjoin
