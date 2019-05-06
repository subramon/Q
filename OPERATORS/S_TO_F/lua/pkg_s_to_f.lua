
local s = [===[
local function <<operator>>(x)
  local expander = require 'Q/OPERATORS/S_TO_F/lua/expander_s_to_f'
  local status, col = pcall(expander, "<<operator>>", x)
  if ( not status ) then if ( col ) then print(col) end end
  assert(status, "Could not execute <<operator>>")
  return col
end
T.<<operator>> = <<operator>>
require('Q/q_export').export('<<operator>>', <<operator>>)
    ]===]

io.output("_s_to_f.lua")
io.write("local T = {} \n")
local ops = assert(require 'operators')
local T = {}
for i, op in ipairs(ops) do
  T[#T+1] = string.gsub(s, "<<operator>>", op)
end
local x = table.concat(T, "\n")
io.write(x)
io.write("\nreturn T\n")
io.close()
