local T = {} 
local function const(x)
  local expander = require 'Q/OPERATORS/S_TO_F/lua/expander_s_to_f'
  local status, col = pcall(expander, "const", x)
  if ( not status ) then if ( col ) then print(col) end end
  assert(status, "Could not execute const")
  return col
end
T.const = const
require('Q/q_export').export('const', const)
    
local function seq(x)
  local expander = require 'Q/OPERATORS/S_TO_F/lua/expander_s_to_f'
  local status, col = pcall(expander, "seq", x)
  if ( not status ) then print("ERROR = ", col) end 
  assert(status, "Could not execute seq")
  return col
end
T.seq = seq
require('Q/q_export').export('seq', seq)
    
local function period(x)
  local expander = require 'Q/OPERATORS/S_TO_F/lua/expander_s_to_f'
  local status, col = pcall(expander, "period", x)
  if ( not status ) then if ( col ) then print(col) end end
  assert(status, "Could not execute period")
  return col
end
T.period = period
require('Q/q_export').export('period', period)
    
local function rand(x)
  local expander = require 'Q/OPERATORS/S_TO_F/lua/expander_s_to_f'
  local status, col = pcall(expander, "rand", x)
  if ( not status ) then if ( col ) then print(col) end end
  assert(status, "Could not execute rand")
  return col
end
T.rand = rand
require('Q/q_export').export('rand', rand)
    
return T
