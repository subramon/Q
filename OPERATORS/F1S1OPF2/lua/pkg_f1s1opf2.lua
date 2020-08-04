local s = [===[
local function <<operator>>(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "<<operator>>", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute <<operator>>")
  return col
end
T.<<operator>> = <<operator>>
require('Q/q_export').export('<<operator>>', <<operator>>)
    ]===]

local pow_s = [===[
local function <<operator>>(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then
    local op
    assert(y)
    if type(y) == "Scalar" then
      y = y:to_num()
    end
    if y == 2 then
      op = "sqr"
    else
      op = "pow"
    end
    local status, col = pcall(expander, op, x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute <<operator>>")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.<<operator>> = <<operator>>
require('Q/q_export').export('<<operator>>', <<operator>>)
    ]===]


io.output("f1s1opf2.lua")
io.write("local T = {} \n")
local ops = assert(require 'Q/OPERATORS/F1S1OPF2/lua/operators')
local T = {}
for i, op in ipairs(ops) do
  if op == "pow" then
    T[#T+1] = string.gsub(pow_s, "<<operator>>", op)
  else
    T[#T+1] = string.gsub(s, "<<operator>>", op)
  end
  loadstring(T[#T])
end
local x = table.concat(T, "\n")
io.write(x)
io.write("\nreturn T\n")
io.close()
-- TODO Is it necessary to create a file? Will the loadstring be enough
