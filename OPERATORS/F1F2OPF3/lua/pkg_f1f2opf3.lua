local s = [===[
local function <<operator>>(x, y, optargs)
  local doc_string = [[ Signature: Q.<<operator>>(x, y, opt_optargs)
  -- This operator performs <<operator>> of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "<<operator>>", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute <<operator>>")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.<<operator>> = <<operator>>
require('Q/q_export').export('<<operator>>', <<operator>>)
    ]===]

io.output("_f1f2opf3.lua")
io.write("local T = {} \n")
local ops = assert(require 'Q/OPERATORS/F1F2OPF3/lua/operators')
local T = {}
for i, op in ipairs(ops) do
  T[#T+1] = string.gsub(s, "<<operator>>", op)
  loadstring(T[#T])
end
local x = table.concat(T, "\n")
io.write(x)
io.write("\nreturn T\n")
io.close()
-- TODO Is it necessary to create a file? Will the loadstring be enough
