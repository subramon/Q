local function is_in (x, X)
  assert(x)
  assert(type(X) == "table")
  for _, v in pairs(X) do 
    if ( v == x ) then return true
    end
  end
  return false
end
return is_in
