local function ifxthenyelsez(x, y)
  if ( x and ( type(x) == "string") and ( #x > 0 ) ) then 
    return x 
  else 
    return y 
  end
end
return  ifxthenyelsez
