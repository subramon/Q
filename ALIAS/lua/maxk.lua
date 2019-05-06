local T = {} 

--[[
Q.maxk() alias wrapper

Q.maxk() : returns maximum k values of input vector
2 usages of maxk():

1)Q.maxk(x, y): 
      which returns two vectors with maximum k values from first input vector 
      and corresponding y values from second input vector
      -- Input arguments:  x and y are of type 'lVector'
      -- Returns        :  2 vectors
                        -- i)  max k values from  x
                        -- ii) corresponding k values from y 
2)Q.maxk(x): 
      which returns one vector with maximum k values from input vector
      -- Input arguments:  x is of type 'lVector'
      -- Returns        :  1 vector
                        -- i)maximum k values from x
-- ]]
local function maxk(x, y, optargs)
  local expander
  local op = "maxk" 
  assert(type(x) == "lVector", "val must be a lVector")
  if type(x) == "lVector" and type(y) == "lVector" then
    expander = require 'Q/OPERATORS/GETK/lua/expander_getk_reducer'
  elseif type(x) == "lVector" then
    expander = require 'Q/OPERATORS/GETK/lua/expander_getk'
  else
    assert(nil, "Invalid arguments")
  end

  local status, ret_1, ret_2 = pcall(expander, op, x, y, optargs)
  if ( not status ) then print(ret_1) end
  --print(status)
  assert(status, "Could not execute maxk")
  return ret_1, ret_1
end

T.maxk = maxk
require('Q/q_export').export('maxk', maxk)