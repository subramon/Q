local Scalar = require 'libsclr'
local f_to_s = require 'Q/OPERATORS/F_TO_S/lua/_f_to_s'

local T = {}
local function fold( fns, vec)
  local status = true
  local  gens = {}
  for i, v in ipairs(fns) do
    gens[i] = f_to_s[v](vec)
  end
  repeat
    for i, v in ipairs(fns) do
      status = gens[i]:next() 
    end
  until not status
  local rvals = {}
  for i, v in ipairs(gens) do
    rvals[i] = gens[i]:eval() 
  end
  return unpack(rvals)
end
T.fold = fold
require('Q/q_export').export('fold', fold)
return T
