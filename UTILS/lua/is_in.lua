local vals 
local function is_in (x, X)
  if ( not vals ) then
    vals = {}
    for k, v in pairs(X) do 
      vals[v] = true
    end
  end
  return vals[x]
end
return is_in
