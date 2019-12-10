--TODO P2 Add to fileops and move to C library 
local assertx = require 'Q/UTILS/lua/assertx'
local function write_to_file(content, fname)
  local file = assertx(io.open(fname, "w+"), "unable to create ", fname)
  -- local str = content:gsub('\n', [[\n]])
  assert(file:write(content))
  assert(file:close())
  return true
end
return write_to_file
