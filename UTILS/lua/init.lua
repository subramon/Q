ffi = require 'ffi' -- TODO take "ffi" value from properties; can be luaFFI path
require 'globals'

-- Shut Down Call Back
local shcb = {}

register_shcb = function (f) 
  table.insert(shcb, f)

end

shutdown = function()
  for i,v in ipairs(shcb) do v() end
end