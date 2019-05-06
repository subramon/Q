local T = {} 

-- Q.add alias wrapper

-- Q.add(x, y, optargs) : performs addition of "two vectors"(vv) or "vector-scalar"(vs)
          -- where x and y can be
              -- type(x) and type(y) is 'lVector'
              -- type(x) is 'lVector' and type(y) is 'Scalar/number'

local function add(x, y, optargs)
  local expander, op 
  if type(x) == "lVector" and type(y) == "lVector" then
    expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
    op = "vvadd"
  elseif type(x) == "lVector" then
    expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
    op = "vsadd"
  else
    assert(nil, "Invalid arguments")
  end
  
  local status, col = pcall(expander, op, x, y, optargs)
  if ( not status ) then print(col) end
  --print(status)
  assert(status, "Could not execute add")
  return col
end

T.add = add
require('Q/q_export').export('add', add)