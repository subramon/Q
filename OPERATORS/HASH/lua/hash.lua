local T = {}
local function hash(f1, optargs)
  local expander = require 'Q/OPERATORS/HASH/lua/expander_hash'
  assert(f1, "no arg f1 to hash")
  local status, col = pcall(expander, f1, optargs)
  if not status then print(col) end
  assert(status, "Could not execute HASH")
  return col
end
T.hash = hash
require('Q/q_export').export('hash', hash)

return T

