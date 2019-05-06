local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
local knn = require 'Q/ML/KNN/lua/knn'
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local chk_params = require 'Q/ML/KNN/lua/chk_params'['chk_params']
local chk_test_sample = require 'Q/ML/KNN/lua/chk_params'['chk_test_sample']


function validate_args(args)
  assert(args.meta_data_file)
  assert(args.data_file)
  assert(args.goal)

  if args.iterations then
    assert(type(args.iterations == "number"))
  else
    args.iterations = 1
  end
  assert(args.iterations > 0)

  if args.split_ratio then
    assert(type(args.split_ratio) == "number")
    assert(args.split_ratio < 1 and args.split_ratio > 0)
  else
    args.split_ratio = 0.7
  end
  assert(args.split_ratio < 1 and args.split_ratio > 0)

  if args.feature_of_interest then
    assert(type(args.feature_of_interest) == "table")
  end
    
  -- number of neighbors we care about
  if args.k then
    assert(type(args.k) == "number")
  else
    args.k = 5
  end

  return args
end

function run_knn(args)
  -- validate args
  local args = validate_args(args)

  local meta_data_file	= args.meta_data_file
  local data_file	= args.data_file
  local is_hdr          = args.is_hdr
  local goal		= args.goal
  local iterations	= args.iterations
  local split_ratio	= args.split_ratio
  local k		= args.k
  local feature_of_interest = args.feature_of_interest

  -- load the data
  local T = Q.load_csv(data_file, dofile(meta_data_file), { is_hdr = is_hdr })

  local accuracy = {}
  for i = 1, iterations do
    -- break into a training set and a testing set
    local Train, Test = split_train_test(T, split_ratio, feature_of_interest)
    local train, g_train, m_train, n_train = extract_goal(Train, goal)
    local test,  g_test,  m_test,  n_test  = extract_goal(Test,  goal)

    -- validate parameters
    local nT, n, ng = chk_params(train, g_train, k)

    -- predict for the test samples
    local predicted_values = {}
    for j = 1, n_test do
      local x = {}
      for k = 1, m_test do
        x[k] = test[k]:get_one(j-1)
      end
      -- validate test sample
      assert(chk_test_sample(x))
      local result = knn(train, g_train, x, k)
      local k_val, k_goal = result:eval()

      local _, _, index = Q.max(Q.numby(utils.table_to_vector(k_goal, g_test:fldtype()), ng)):eval()
      predicted_values[j] = index:to_num()
    end

    -- prepare table of actual goal values
    local actual_values = {}
    for k = 1, n_test do
      actual_values[k] = g_test:get_one(k-1):to_num()
    end

    -- calculate accuracy
    local acr = ml_utils.accuracy_score(actual_values, predicted_values)
    accuracy[#accuracy + 1] = acr 
  end
  return ml_utils.average_score(accuracy), accuracy
end

return run_knn
