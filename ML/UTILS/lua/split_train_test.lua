local Q = require 'Q'
local Scalar = require 'libsclr'
local function split (
  T,  -- table of m lVectors of length n
  split_ratio,  -- Scalar between 0 and 1 
  features_to_consider,
  seed
  )
  assert(T)
  assert(type(T) == "table")
  if ( type(split_ratio) == "number" ) then
    split_ratio = assert(Scalar.new(split_ratio, "F4"))
  elseif ( type(split_ratio) == "Scalar" ) then
    assert(split_ratio:fldtype() == "F4")
  end
  assert(Scalar.gt(split_ratio, 0)) -- TODO Improve P3
  assert(Scalar.lt(split_ratio, 1)) -- TODO Improve P3

  local Train = {}
  local Test = {}

  local n
  for k, v in pairs(T) do
    if ( not n ) then 
      n = v:length()
    else
      assert(n == v:length())
    end
  end
  --==============================
  local features_of_interest
  if not features_to_consider then
    features_of_interest = {}
    for k, _ in pairs(T) do
      features_of_interest[#features_of_interest + 1] = k
    end
  else
    features_of_interest = features_to_consider
  end
  assert(type(features_of_interest) == "table")
  assert(#features_of_interest > 0)

  local num_features = 0
  for _, feature1 in pairs(features_of_interest) do 
    local found = false
    for feature2, _ in pairs(T) do 
      if ( feature1 == feature2 ) then found = true break end 
    end
    assert(found, "Feature not found in data set " .. feature1)
    num_features = num_features + 1
  end
  assert(num_features > 0)
  --=======================================
  local random_vec = Q.rand({lb = 0, ub = 1, qtype = "F4", len = n, seed = seed})
  local random_vec_bool = Q.vsleq(random_vec, split_ratio)
  local n1, n2 = Q.sum(random_vec_bool):eval()
  -- TODO P2: Should not need to convert number to scalar for comparison
  assert(( n1:to_num() > 0 ), "cannot return null Vectors")
  assert(( n1 ~= n2 ), "cannot return null Vectors")
  --=======================================
  local T_train = {}
  local T_test  = {}
  for _, feature in pairs(features_of_interest) do
    T_train[feature] = Q.where(T[feature], random_vec_bool):eval()
    T_test [feature] = Q.where(T[feature], Q.vnot(random_vec_bool)):eval()
  end
  return T_train, T_test
end
return split
