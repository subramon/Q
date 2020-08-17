local json = require 'simdjson'
local x = ' { "abc" : "xyz", "def" : 123, "ghi" : true } '
local y = json.parse(x)
for k, v in pairs(y) do print(k, v, type(v)) end 
