local T = {} 
local function ainb(x, y, optargs)
  local expander = require 'Q/OPERATORS/AINB/lua/expander_ainb'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "ainb", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute ainb")
    return col
  end
  assert(nil, "Bad arguments to ainb")
end
T.ainb = ainb
require('Q/q_export').export('ainb', ainb)
    
return T
