local T = {} 
local function min(x, y, optargs)
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
  local status, z = pcall(expander, "min", x, y)
  if ( not status ) then print(z) end
  assert(status, "Could not execute min")
  return z
end
T.min = min
require('Q/q_export').export('min', min)
    
local function max(x, y, optargs)
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
  local status, z = pcall(expander, "max", x, y)
  if ( not status ) then print(z) end
  assert(status, "Could not execute max")
  return z
end
T.max = max
require('Q/q_export').export('max', max)
    
local function sum(x, y, optargs)
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
  local status, z = pcall(expander, "sum", x, y)
  if ( not status ) then print(z) end
  assert(status, "Could not execute sum")
  return z
end
T.sum = sum
require('Q/q_export').export('sum', sum)
    
local function sum_sqr(x, y, optargs)
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
  local status, z = pcall(expander, "sum_sqr", x, y)
  if ( not status ) then print(z) end
  assert(status, "Could not execute sum_sqr")
  return z
end
T.sum_sqr = sum_sqr
require('Q/q_export').export('sum_sqr', sum_sqr)
    
local function is_next(x, y, optargs)
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
  local status, z = pcall(expander, "is_next", x, y)
  if ( not status ) then print(z) end
  assert(status, "Could not execute is_next")
  return z
end
T.is_next = is_next
require('Q/q_export').export('is_next', is_next)
    
return T
