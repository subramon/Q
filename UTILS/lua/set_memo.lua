local qconsts = require 'Q/UTILS/lua/q_consts'
local function set_memo(is_memo)
  assert(is_memo ~= nil, "is_memo value needs to be provided")
  assert(type(is_memo) == "boolean")
  qconsts.is_memo = is_memo
end
return require('Q/q_export').export('set_memo', set_memo)
