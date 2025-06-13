local pr = require 'Q/OPERATORS/PRINT/lua/print_csv'
local T = {}
local function head(x, n)
  n = n or 10
  assert( (type(n) == "number") and (n > 0 ) ) 
  if ( type(x) == "table" ) then 
    for k, v in pairs(x) do 
      assert(type(v) == "lVector")
      v:eval()
    end
    local Tpr = {}
    local names = {}
    for k, v in pairs(x) do 
      Tpr[#Tpr+1] = v
      names[#names+1] = v:name()
    end
    print(table.concat(names, ","))
    pr(Tpr, { filter = { lb = 0, ub = n} })
  elseif ( type(x) == "lVector" ) then 
    x:eval()
    pr(x,  { filter = { lb = 0, ub = n} })
  else
    error("invalid first argument for head()")
  end
  --===============================
end
T.head = head
require('Q/q_export').export('head', head)
return T
