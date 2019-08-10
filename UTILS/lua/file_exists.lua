local function file_exists(name)
  assert(type(name) == "string")
  local f = io.open(name, "r")
  if f ~= nil then 
    io.close(f)
    return true
  else
    return false
  end
end
return file_exists
