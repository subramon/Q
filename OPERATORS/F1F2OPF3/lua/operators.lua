local t1 = require 'Q/OPERATORS/F1F2OPF3/lua/f1f2opf3_operators'
local t2 = require 'Q/OPERATORS/F1F2OPF3/lua/concat_operators'
for i, v in ipairs(t2) do t1[#t1+1] = v end

-- for i, v in ipairs(t1) do print(i, v) end
return t1

