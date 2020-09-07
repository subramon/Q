local qcfg = require 'Q/UTILS/lua/qcfg'
local function set_memo(is_memo)
  if (type(is_memo) ~= "boolean") then return nil end 
  qcfg._modify("is_memo", is_memo)
  return true
end
return require('Q/q_export').export('set_memo', set_memo)
