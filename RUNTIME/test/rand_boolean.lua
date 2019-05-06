local function rand_boolean()
  local x = math.floor(math.random() * 2)
  if ( x == 0 ) then 
    return true 
  else 
    return false
  end
end
return rand_boolean
