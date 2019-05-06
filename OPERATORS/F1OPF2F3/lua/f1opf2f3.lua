local T = {} 
local function split(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2F3/lua/expander_f1opf2f3'
  assert(x)
  local status, y, z = pcall(expander, "split", x, optargs)
  if ( not status ) then print(y) end
  assert(status, "Could not execute [split]")
  return y, z
end
T.split = split
require('Q/q_export').export('split', split)
    
