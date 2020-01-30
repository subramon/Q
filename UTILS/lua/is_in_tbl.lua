local vals 
local function is_in (x, X)
  if ( not vals ) then
    vals = {}
    for k, v in pairs(X) do 
      vals[v] = true
    end
  else
    print("=================")
    print(type(vals))
    for k, v in pairs(vals) do print(k,v) end 
    print("=================")
  end
  return vals[x]
end
return is_in
