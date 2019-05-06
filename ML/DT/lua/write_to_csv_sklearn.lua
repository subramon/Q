local tablex = require 'pl.tablex'
local utils = require 'Q/UTILS/lua/utils'

local write_to_csv = function(result, csv_file_path, sep)
  assert(result)
  assert(type(result) == "table")
  assert(csv_file_path)
  assert(type(csv_file_path) == "string")
  sep = sep or ','
  
  local file = assert(io.open(csv_file_path, "w"))

  local required_param = {"f1_score","accuracy","mcc","precision","payout", "recall"}
  local tbl = {}
  for i, v in pairs(result) do
    if utils["table_find"](required_param, i) ~= nil then 
      tbl[i] = v
    end
  end
  --local plpretty = require "pl.pretty"
  --plpretty.dump(tbl)

  local col_name = ""
  local value_row = ""
  local first_value = true
  for i,v in pairs(tbl) do
    if first_value then
      col_name = i
      value_row = v[1]
      first_value = false
    else
      col_name = col_name .. "," .. i
      value_row = value_row .. "," .. v[1]
    end
  end
  file:write(col_name .. "\n")
  file:write(value_row .. "\n")

  file:close()
end

return write_to_csv
