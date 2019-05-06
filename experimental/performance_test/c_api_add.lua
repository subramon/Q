require("add")

limit = 100000000
if ( arg ) and arg[1] then 
  limit = tonumber(arg[1])
end

local function sum_of_n()
  local output = add(limit)
end

for i = 1, 100 do
  sum_of_n()
end
