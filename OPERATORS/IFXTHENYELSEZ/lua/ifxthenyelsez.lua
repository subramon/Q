local T = {} 
local function ifxthenyelsez(x, y, z)
  local expander
  assert(type(x) == "lVector")
  if ( ( type(y) == "lVector") and ( type(z) == "lVector" ) ) then
    expander = require 'Q/OPERATORS/IFXTHENYELSEZ/lua/vv_ifxthenyelsez'
  elseif ( ( type(y) == "lVector") and ( type(z) == "Scalar" ) ) then
    expander = require 'Q/OPERATORS/IFXTHENYELSEZ/lua/vs_ifxthenyelsez'
  elseif ( ( type(y) == "Scalar") and ( type(z) == "lVector" ) ) then
    expander = require 'Q/OPERATORS/IFXTHENYELSEZ/lua/sv_ifxthenyelsez'
  elseif ( ( type(y) == "Scalar") and ( type(z) == "Scalar" ) ) then
    expander = require 'Q/OPERATORS/IFXTHENYELSEZ/lua/ss_ifxthenyelsez'
  else
    assert(nil, "Bad input types for ifxthenyelsez")
  end
  local status, col = pcall(expander, x, y, z)
  if ( not status ) then print(col) end
  assert(status, "Could not execute ifxthenyelsez")
  return col
end
T.ifxthenyelsez = ifxthenyelsez
require('Q/q_export').export('ifxthenyelsez', ifxthenyelsez)
    
return T
