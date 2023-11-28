local T = {}
local function join(src_val, src_lnk, dst_lnk, join_types, optargs)
  local expander = require 'Q/OPERATORS/JOIN/lua/expander_join'
  local status, T = pcall(expander, "join", src_val, src_lnk, dst_lnk, join_types, optargs)
  if not status then print(T) end
  assert(status, "Could not execute join")
  return T -- we return a table 
end
T.join = join
require('Q/q_export').export('join', join)

return T
