-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  local x_len = 65537
  local y = Q.rand({ lb = 0, ub = 1, seed = 1234, qtype = "I1", len = x_len } )
  local c1 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F8", len = x_len } )
  local c2 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F8", len = x_len } )
  local X = {c1, c2}

  local lengths = {}
  for i, _ in ipairs(X) do 
    lengths[i] = 0
  end

  -- state before eval is called
  for iter = 1, 100 do 
    for i, X_i in ipairs(X) do
      assert(X_i:is_eov() == false)
      assert(X_i:length() == nil)
      assert(X_i:num_elements() == 0)
    end
  end
  -- state after eval is called
  for i, X_i in ipairs(X) do
    X_i:eval()
    if ( lengths[i] == 0 ) then
      lengths[i] = X_i:length()
    else
      assert(lengths[i] == X_i:length())
      assert(X_i:length() == X_i:num_elements())
    end
    local A = {}
    A[i] = {}
    for j, X_j in ipairs(X) do
      A[i][j] = Q.sum(Q.vvmul(X_i, X_j))
      assert(type(A[i][j]) == "Reducer")
      local x = A[i][j]:eval()
      assert(type(A[i][j]) == "Reducer")
      assert(type(x) == "Scalar")
    end
  end

end
--=======================================
return tests

