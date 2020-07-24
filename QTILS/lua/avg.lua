local libsclr = require 'libsclr'
local T = {}
local function avg(x)
  local Q = require 'Q'
  assert(x and type(x) == "lVector", "input must be of type lVector")
  local sum, count = Q.sum(x):eval()
  if count:to_num() > 0 then
    return  sum:conv("F8") / count
  else
    return nil
  end
end
T.avg = avg
require('Q/q_export').export('avg', avg)
return T
