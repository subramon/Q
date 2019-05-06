local function multiple8(n)
  assert(type(n) == "number")
  assert(n > 0)
  return math.ceil(n/8)*8
end 
return multiple8
