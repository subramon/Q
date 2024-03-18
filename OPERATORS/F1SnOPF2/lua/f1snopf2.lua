local T = {} 
--==========================================================
local function vSeq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1SnOPF2/lua/expander_f1snopf2'
  local status, col = pcall(expander, "vSeq", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vSeq")
  return col
end
T.vSeq = vSeq
require('Q/q_export').export('vSeq', vSeq)
--==========================================================
--[[ TODO 
local function vSneq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1SnOPF2/lua/expander_f1snopf2'
  local status, col = pcall(expander, "vSneq", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vSneq")
  return col
end
T.vSneq = vSneq
require('Q/q_export').export('vSneq', vSneq)
--==========================================================
--]]
return T
