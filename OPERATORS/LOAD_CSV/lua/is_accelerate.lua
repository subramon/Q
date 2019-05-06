local function is_accelerate(M)
  assert(type(M) == "table")
  local nC = #M
  assert(nC > 0)
  for i = 1, nC do
    assert(type(M[i].is_load) == "boolean")
    if ( ( M[i].is_load ) and 
         ( ( (M[i].qtype == "SC") or M[i].qtype == "SV" ) ) ) then 
      return false
    end
  end
  return true
end
return is_accelerate