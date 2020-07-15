
local s = [===[
local function <<operator>>(x)
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
  local status, z = pcall(expander, "<<operator>>", x)
  if ( not status ) then print(z) end
  assert(status, "Could not execute <<operator>>")
  return z
end
T.<<operator>> = <<operator>>
require('Q/q_export').export('<<operator>>', <<operator>>)
    ]===]

io.output("f_to_s.lua")
io.write("local T = {} \n")
local ops = assert(require 'Q/OPERATORS/F_TO_S/lua/operators')
local T = {}
for i, op in ipairs(ops) do
  T[#T+1] = string.gsub(s, "<<operator>>", op)
end
local x = table.concat(T, "\n")
io.write(x)
io.write("\nreturn T\n")
io.close()
