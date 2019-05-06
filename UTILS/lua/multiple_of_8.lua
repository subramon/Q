return function (x )
  assert(x) 
  assert(type(x) == "number")
  assert(x > 0)
  return math.ceil(x / 8.0 ) * 8
end
