local Q = require 'Q'
local Scalar = require 'libsclr'
local function split_train_test (
  T,  -- table of m lVectors of length n
  split_ratio,  -- Scalar between 0 and 1 
  seed
  )
  assert(T)
  assert(type(T) == "table")
  for k, v in pairs(T) do 
    assert(type(v) == "lVector") 
    assert(v:is_eov())
  end 
  assert(type(split_ratio) == "number" )
  assert(( split_ratio > 0 ) and ( split_ratio < 1 )) 
  split_ratio = Scalar.new(split_ratio, "F4")
  assert(split_ratio:fldtype() == "F4")

  local Train = {}
  local Test = {}

  -- check all vectors same length
  local n
  for k, v in pairs(T) do
    if ( not n ) then 
      n = v:length()
    else
      assert(n == v:length())
    end
  end
  --==============================
  local random_vec = Q.rand({lb = 0, ub = 1, qtype = "F4", len = n, seed = seed})
  local is_train = Q.vsleq(random_vec, split_ratio):eval()
  local n1, n2 = Q.sum(is_train):eval()
  print(n1, n2)
  -- split cannot be such that all go to test or all go to train
  assert(n1:to_num() > 0)
  assert(n1 ~= n2)
  --=======================================
  local is_test = Q.vnot(is_train):eval()
  local T_train = {}
  local T_test  = {}
  for k, v in pairs(T) do 
    T_train[k] = Q.where(T[k], is_train)
    T_test [k] = Q.where(T[k], is_test)
  end
  return T_train, T_test
end
return split_train_test
