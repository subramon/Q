local s = [===[
local function <<operator>>(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2F3/lua/expander_f1opf2f3'
  if type(x) == "Column" then 
    local status, col1, col2 = pcall(expander, "<<operator>>", x optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute <<operator>>")
    return col1, col2
  else
    assert(nil, "Invalid tpe for input to <<operator>>")
  end
end
T.<<operator>> = <<operator>>
require('Q/q_export').export('<<operator>>', <<operator>>)
    ]===]

io.output("f1opf2f3.lua")
io.write("local T = {} \n")
local ops = assert(require 'operators')
local T = {}
for i, op in ipairs(ops) do
  T[#T+1] = string.gsub(s, "<<operator>>", op)
  loadstring(T[#T])
end
local x = table.concat(T, "\n")
io.write(x)
io.write("\nreturn T\n")
io.close()
