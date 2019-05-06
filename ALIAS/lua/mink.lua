local T = {} 

--[[
Q.mink() alias wrapper

Q.mink() : returns minimum k values of input vector
2 usages of mink():

1)Q.mink(x, y): 
      which returns two vectors with minimum k values from first input vector 
      and corresponding y values from second input vector
      -- Input arguments:  x and y are of type 'lVector'
      -- Returns        :  2 vectors
                        -- i)  min k values from  x
                        -- ii) corresponding k values from y 
2)Q.mink(x): 
      which returns one vector with minimum k values from input vector
      -- Input arguments:  x is of type 'lVector'
      -- Returns        :  1 vector
                        -- i)minimum k values from x
-- ]]
local function mink(x, y, optargs)
  local expander
  local op = "mink" 
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
  assert(status, "Could not execute mink")
  return ret_1, ret_1
end

T.mink = mink
require('Q/q_export').export('mink', mink)