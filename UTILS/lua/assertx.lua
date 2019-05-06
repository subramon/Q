-- When assertx is used it concats all the args except the condition
-- assertx only conditionally creats the concat string so we dont have to pay
-- the cost always
local assertx = function(a, ...)
  if a then return a, ... end
  if ... ~= nil  then
    local args = {...}
    error(table.concat(args), 2)
  else
    error("assertion failed!", 2)
  end
end

return assertx
