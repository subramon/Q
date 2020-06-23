local tablex = require 'pl.tablex'

local write_to_csv = function(result, csv_file_path, sep)
  assert(result)
  assert(type(result) == "table")
  assert(csv_file_path)
  assert(type(csv_file_path) == "string")
  local sep = sep or ','
  local file = assert(io.open(csv_file_path, "w"))
  local hdr = 'alpha'
  for k, v in pairs(result) do
    for k1, v1 in pairs(v) do
      hdr = hdr .. "," .. k1 .. "," .. k1 .. "_sd"
    end
    break
  end
  file:write(hdr .. "\n")
  for k, v in tablex.sort(result) do
    file:write(k)
    for k1, v1 in pairs(v) do
      local avg_score = v1.avg
      local sd_score = v1.sd
      file:write("," .. avg_score .. "," .. sd_score)
    end
    file:write("\n")
  end
  file:close()
end

return write_to_csv
