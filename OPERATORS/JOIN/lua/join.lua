local T = {}
-- TODO: Documentation and usage
-- type 1 ops
-- type 2 ops
local function join(x, y, z, op, optargs)
  local expander = require 'Q/OPERATORS/JOIN/lua/expander_join'
  assert(x, "no arg x to join")
  assert(z, "no arg z to join")
  assert(op, "Join type must be provided")
  assert(type(x) == "lVector", "arg x must be a lVector")
  assert(type(z) == "lVector", "arg z must be a lVector")
  assert(type(op) == "string", "Join type must be a string")
  if ( op == "sum" or op == "min" or op == "max" or op == "and" or op == "or" or op == "any") then
    assert(y, "no arg y to join")
    assert(type(y)== "lVector", "arg y must be a lVector")
  end

  local status, col1 = pcall(expander, "join", x, y, z, op, optargs)
  if not status then print(col1) end
  assert(status, "Could not execute JOIN")
  return col1
end
T.join = join
require('Q/q_export').export('join', join)

return T
