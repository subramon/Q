local T = {}
local function bin_place(x, aux, lb, ub, cnt, optargs)
  -- Q.place(x, b)
  -- x is a set of values. Output is y that is permuyed values of x
  -- Bin(x[i]) = b => lb[b] <= x[i] < ub[b]
  -- Offset[i] == 0
  -- Offset[j] = Offset[j-1] + cnts[j-1]. 
  -- Let b := Bin(x[i])
  -- Place x[i] in y[Offset[b]] and increment Offset[b]
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
  local expander = assert(require 'Q/OPERATORS/BIN_PLACE/lua/expander_bin_place')
  local status, z, w = pcall(expander, x, aux, lb, ub, cnt, optargs)
  if ( not status ) then print(z) end
  assert(status, "Could not execute bin_place")
  return z, w
end
T.bin_place = bin_place
require('Q/q_export').export('bin_place', bin_place)
    
return T
