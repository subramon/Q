local T = {} 
local function min(x, optargs)
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
  local status, z = pcall(expander, "min", x, optargs)
  if ( not status ) then print(z) end
  assert(status, "Could not execute min")
  return z
end
T.min = min
require('Q/q_export').export('min', min)
    
local function max(x, optargs)
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
  local status, z = pcall(expander, "max", x, optargs)
  if ( not status ) then print(z) end
  assert(status, "Could not execute max")
  return z
end
T.max = max
require('Q/q_export').export('max', max)
    
local function sum(x, optargs)
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
  local status, z = pcall(expander, "sum", x, optargs)
  if ( not status ) then print(z) end
  assert(status, "Could not execute sum")
  return z
end
T.sum = sum
require('Q/q_export').export('sum', sum)
    
return T
