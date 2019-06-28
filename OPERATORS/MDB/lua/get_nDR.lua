local function get_nDR(Tk)
  assert(type(Tk) == "table")
  local nDR = {}
  local vecs = {}
  for k, v in pairs(Tk) do 
    assert(type(v) == "table")
    nDR[k] = #v
    assert(nDR[k] > 0)
    for k2, v2 in pairs(v) do 
      for k3, v3 in pairs(v2) do 
        -- print(k, k2, k3, type(v3))
        assert(type(v3) == "lVector")
        assert(v3:fldtype() == "I1")
        assert(not v3:has_nulls())
        vecs[#vecs+1] = v3
      end
    end
  end
  return nDR, vecs
end
return get_nDR
