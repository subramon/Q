local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local len = qconsts.chunk_size + 1
  -- set len to more than a chunk and so that exp_rslt for numby is correct
  while ( ( len % 3 ) ~= 1 ) do
    len = len + 1
  end
  local nb = 3
  local b = Q.period({ len = len, start = 0, by = 1, period = 3, qtype = "I1"}):eval()
  -- b has values 0, 1, 2
  local period = 6
  local a = Q.period({ len = len, start = 10, by = 10, period = period, qtype = "I4"}):eval()
  -- a has values 10, 20, 30, 40, 50, 60, 10, 20, 30, 40, 50, 60, ...
  local operators = { "min", "max", "num" }
  for k, operator in ipairs(operators ) do 
    local rslt, exp_rslt
    if ( operator == "min" ) then 
      rslt = Q.minby(a, b, nb, {is_safe = false})
      exp_rslt = Q.mk_col({10, 20, 30}, "I4")
    elseif ( operator == "max" ) then 
      rslt = Q.maxby(a, b, nb, {is_safe = false})
      exp_rslt = Q.mk_col({40, 50, 60}, "I4")
    elseif ( operator == "num" ) then 
      rslt = Q.numby(b, nb, {is_safe = false})
      rslt:eval()
      local x = math.floor(len / 3) 
      exp_rslt = Q.mk_col({x+1, x, x}, "I4")
    else
      assert(nil)
    end
    -- when you do minby or maxby, 
    --   if input vector is I*, output vector is I*
    --   if input vector is F*, output vector is F*
    -- when you do numby
    --   output vector is I8
    --assert(rslt:fldtype() == "I8")
    -- verify
    assert(rslt:length() == nb)
    local n1, n2 = Q.sum(Q.vvneq(rslt, exp_rslt)):eval()
    assert(n1:to_num() == 0)
  end
  print("Test t1 completed")
end

return tests
