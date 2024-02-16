local T = {}
local function bin_count(x, y)
  -- Q.count(x, y): 
  -- x is a set of values
  -- y is a set of bin boundaries. Say that there are n of them
  -- We return z which is a set of n+1 values
  -- For example, let x = 1, 2, 3, 4, 5, 6, 7, 8, 9
  -- For example, let y = 4, 7
  -- x does not need to be sorted 
  -- y needs to be sorted ascending and unique
  -- z[0] = 3 (for values 1 2 3 )
  -- z[1] = 4 (for values 4 5 6 )
  -- z[2] = 4 (for values 7 8 9 )
  -- Note that \sum_i z[i] = |x|
  -- z is of type I8 (which is overkill)
  -- y needs to be fully materialized
  local expander = assert(require 'Q/OPERATORS/BIN_COUNT/lua/expander_bin_count')
  local status, z = pcall(expander, x, y)
  if ( not status ) then print(z) end
  assert(status, "Could not execute bin_count")
  return z
end
T.bin_count = bin_count
require('Q/q_export').export('bin_count', bin_count)
    
return T
