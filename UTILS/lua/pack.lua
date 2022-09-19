local mk_col     = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local base_qtype = require 'Q/UTILS/lua/is_base_qtype'

local T = {}

-- Q.pack(tbl, qtype) : creates vector of given qtype from input table
          -- Return value:
            -- vector

-- Convention: Q.pack(tbl, qtype)
-- 1) tbl   : table_of_scalars/numbers
-- 2) qtype : qtype of required vector

local function pack(tbl, qtype)
  assert(tbl and type(tbl) == "table", "input must be a table")
  assert(#tbl > 0, "Input table has no entries")
  -- CAUTION: This is a slow operator. Useful for quick testing
  -- Do not use when performance is critical 
  -- for base_qtype, what if input qtype is 'B1'
  assert(type(qtype) == "string" and base_qtype(qtype))
  local col = assert(mk_col(tbl, qtype)) -- internally calling mk_col
  return col
end
T.pack = pack
require('Q/q_export').export('pack', pack)
return T
