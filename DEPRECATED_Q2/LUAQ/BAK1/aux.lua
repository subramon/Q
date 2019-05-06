-- See if the file exists
function file_exists(file)
  assert(tostring(file))
  local f = io.open(file, "rb")
  if f then f:close() end
  -- print("Checking for file " .. file);
  return f ~= nil
end

function fsize (file)
  print("file = " .. file)
  local current = file:seek()      -- get current position
  local size = file:seek("end")    -- get file size
  file:seek("set", current)        -- restore position
  return size
end

function file_size (file)
  local xlfs = require "lfs"
  local sz = assert(xlfs.attributes(file, "size"))
  return sz
end
