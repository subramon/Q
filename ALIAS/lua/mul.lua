local T = {} 

-- Q.mul alias wrapper

-- Q.mul(x, y, optargs) : performs multiplication of "two vectors"(vv) or "vector-scalar"(vs)
          -- where x and y can be
              -- type(x) and type(y) is 'lVector'
              -- type(x) is 'lVector' and type(y) is 'Scalar/number'

local function mul(x, y, optargs)
  local expander, op 
  if type(x) == "lVector" and type(y) == "lVector" then
    expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
    op = "vvmul"
  elseif type(x) == "lVector" then
    expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
    op = "vsmul"
  else
    assert(nil, "Invalid arguments")
  end
  
  local status, col = pcall(expander, op, x, y, optargs)
  if ( not status ) then print(col) end
  --print(status)
  assert(status, "Could not execute mul")
  return col
end

T.mul = mul
require('Q/q_export').export('mul', mul)