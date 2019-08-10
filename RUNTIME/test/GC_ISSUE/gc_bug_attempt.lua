-- tried to see whether the fact that A is not used directly by
-- foobar would cause Lua to garbage collect it
-- That did not happen - which is the correct behavior
local function foo()
  local A = {}
  local n = 1048576
  for i = 1, n do A[i] = i end
  local function bar()
    local sum = 0
    for i = 1, n do sum = sum + A[i] end
    return sum
  end
  local ctr = 0
  local function foobar()
    if (  ( ctr % 1000 )  == 0 ) then 
      print(ctr, bar())
    end
      ctr = ctr + 1 
  end
  return foobar
end

local n = 1048576
x = foo()
for i = 1, n do 
  x()
  collectgarbage()
end


