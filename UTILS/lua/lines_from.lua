local function lines_from(file)
  assert(type(file) == "string")
  local function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
  end
  -- see if the file exists
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end
return lines_from
-- local X = lines_from("_x.csv")
