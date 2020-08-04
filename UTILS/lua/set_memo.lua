local qconsts = require 'Q/UTILS/lua/q_consts'
local function set_memo(is_memo)
  assert(type(is_memo) == "boolean")
  package.loaded['Q/UTILS/lua/q_consts'].is_memo = is_memo
end
return require('Q/q_export').export('set_memo', set_memo)
