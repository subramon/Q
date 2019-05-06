local ab = require 'core'
local JSON = require "JSON"


ab_struct = ab.init_ab("My_Config")
local ab_tbl = {}
ab_tbl['factor'] = 2
out_json = ab.sum_ab(ab_struct, JSON:encode(ab_tbl))
out_tbl = JSON:decode(out_json)
for i, v in pairs(out_tbl) do
  print(i, v)
end
ab.print_ab(ab_struct)
ab.free_ab(ab_struct)
print("=============================================")
