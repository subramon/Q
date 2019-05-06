-- local Q = require 'Q'
local vvgt = (require "Q/OPERATORS/F1F2OPF3/lua/_f1f2opf3").vvgt
local ifxthenyelsez = (require "Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez").ifxthenyelsez
local vvpromote = (require "Q/QTILS/lua/vvpromote").vvpromote

local T = {} 
local function vvmax(x, y)

  assert(x and type(x) == "lVector")
  assert(y and type(y) == "lVector")
  x, y = vvpromote(x, y)
  local t1 = vvgt(x, y)
  local t2 = ifxthenyelsez(t1, x, y)
  return t2
end
T.vvmax = vvmax
require('Q/q_export').export('vvmax', vvmax)
return T
