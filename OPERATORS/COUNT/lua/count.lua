local T = {}
local function count(x, y)
  -- Q.count(x, y): 
    -- counting the occurrences of a given value(i.e. y)from the given vector(i.e. x)
        -- returns count (Scalar of type I8) of respective given value
        -- else returns 0 (no occurrence)

  -- Convention: Q.count(vector, value)
  -- 1) vector : a vector other than B1 qtype
  -- 2) value  : number or Scalar value
  local expander = assert(require 'Q/OPERATORS/COUNT/lua/expander_count')
  local status, z = pcall(expander, "count", x, y)
  if ( not status ) then print(z) end
  assert(status, "Could not execute count")
  return z
end
T.count = count
require('Q/q_export').export('count', count)
    
return T
