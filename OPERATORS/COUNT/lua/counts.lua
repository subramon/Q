local T = {}
local function counts(x, y)
  -- Q.counts(x, y): 
    -- counting the occurrences of a given value(i.e. y)from the given vector(i.e. x)
        -- returns count (Scalar of type I8) of respective given value
        -- else returns 0 (no occurrence)

  -- Convention: Q.counts(vector, value)
  -- 1) vector : a vector other than B1 qtype
  -- 2) value  : number or Scalar value
  print("In COUNTS")
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/COUNT/lua/expander_counts')
  local status, z = pcall(expander, "counts", x, y)
  if ( not status ) then print(z) end
  assert(status, "Could not execute counts")
  return z
end
T.counts = counts
require('Q/q_export').export('counts', counts)
    
return T