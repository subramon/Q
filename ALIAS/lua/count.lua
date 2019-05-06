local T = {} 

--[[
Q.count() alias wrapper

Q.count() : performs occurrence count of input vector
2 usages of count():

1)Q.count(x): which returns 'unique' and 'count' values
      -- Input arguments:  x is of type 'lVector'
      -- Returns        :  2 vectors
                        -- i)  unique values
                        -- ii) count of the values
                
2) Q.count(x, y): which returns occurence of y from x
      -- Input arguments:  x is of type 'lVector' and y can be 'Scalar/Number'
      -- Returns        :  Scalar of type 'I8'
                        -- i)  occurrence count of given value(y)

3) Q.count(x, y): which returns 'unique' ,'count' and 'sum' values
      -- Input arguments:  x is of type 'lVector' and y is of type B1 'lVector'
      -- Returns        :  3 vectors
                        -- i)  unique values
                        -- ii) count of the values
                        -- iii)sum of respective B1 values
-- ]]
local function count(x, y, optargs)
  local expander, op 
  if y and type(y) ~= "lVector" then
    expander = require 'Q/OPERATORS/COUNT/lua/expander_counts'
    op = "counts"
  else
    expander = require 'Q/OPERATORS/UNIQUE/lua/expander_unique'
    op = "unique"
  end

  local status, ret_1, ret_2, ret_3 = pcall(expander, op, x, y, optargs)
  if ( not status ) then print(ret_1) end
  --print(status)
  assert(status, "Could not execute count")
  return ret_1, ret_2, ret_3
end

T.count = count
require('Q/q_export').export('count', count)
