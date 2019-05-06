-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local sum_prod = require( 'Q/ML/LOGREG/lua/sum_prod' )

local test = {}

test.t1 = function ()
  local c1 = Q.mk_col ( {1, 2, 0, 2} , "I4")
  local c2 = Q.mk_col ( {3, 2, 1, 3} , "I4")
  local c3 = Q.mk_col ( {4, 1, 1, 1} , "I4")

  local X = {c1, c2, c3}
  local w = Q.mk_col ( { 2, 0, 1, 4} , "I4")

  local A = sum_prod(X, w)
  for i = 1, #A do
    for j = 1, #A do
      print(i, j, A[i][j])
    end
    print("================")
  end
  print("SUCCESS")
  os.exit()
end
return test
