local T = {} 
local function drop_nulls(y, sval)
  local Q = require 'Q'
  assert(y)
  assert(type(y) == "lVector")
  if ( not y:has_nulls() ) then 
    return y 
  end
  -- return Q.ifxthenyelsez(y:nn_vec(), y, sval):drop_nulls()
  return Q.ifxthenyelsez(y:nn_vec(), y, sval)
end
T.drop_nulls = drop_nulls
require('Q/q_export').export('drop_nulls', drop_nulls)
    
return T
