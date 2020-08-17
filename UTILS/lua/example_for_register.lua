local function foo(x, y)
  assert(x == y, "some error message")
  return "hello", "world","foobar"
end

local function bar()
  local x = 2
  local y = 2
  local rvals = {pcall(foo, x, y)}
  local xvals = {}
  print("first return from pcall = ", rvals[1])
  for  k, v in pairs(rvals) do 
    if ( k > 1 ) then 
      xvals[#xvals+1] = rvals[k]
    end
  end
  return unpack(xvals)
end 

local x, y, z, w = bar()
print("x = ", x)
print("y = ", y)
print("z = ", z)
print("w = ", w)
