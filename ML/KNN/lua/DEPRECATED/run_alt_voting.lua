local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'
local alt_voting = require 'Q/ML/KNN/lua/alt_voting'

local get_train_test_split = function(split_ratio, T, feature_column_indices)
  local Train = {}
  local Test = {}
  local total_length
  for i, v in pairs(T) do
    total_length = v:length()
    break
  end
  local random_vec = Q.rand({lb = 0, ub = 1, qtype = "F4", len = total_length}):eval()
  local random_vec_bool = Q.vsleq(random_vec, split_ratio):eval()
  if not feature_column_indices then
    local column_indices = {}
    for i, _ in pairs(T) do
      column_indices[#column_indices + 1] = i
    end
    feature_column_indices = column_indices
  end
  assert(feature_column_indices)
  for _, v in pairs(feature_column_indices) do
    Train[v] = Q.where(T[v], random_vec_bool):eval()
    Test[v] = Q.where(T[v], Q.vnot(random_vec_bool)):eval()
  end
  return Train, Test
end

local get_accuracy = function(expected_val, predicted_val)
  assert(type(expected_val) == "table")
  assert(type(predicted_val) == "table")
  assert(#expected_val == #predicted_val)
  local correct = 0
  for i = 1, #expected_val do
    if expected_val[i] == predicted_val[i] then
      correct = correct + 1
    end
  end
  return (correct/#expected_val)*100
end

local get_average = function(accuracy_list)
  local average = 0
  for i = 1, #accuracy_list do
    average = average + accuracy_list[i]
  end
  average = average / #accuracy_list
  return average
end

-- TODO: Think of interface for production mode where input_sample, alpha will be given,
-- you need  to predict the goal value (assuming data is already loaded)
local run_knn = function(args)
  -- It's assumed that data is already loaded into 'T' variable
  -- 'T' will be a table having vectors as it's elements

  local accuracy = {}

  assert(type(args) == "table")

  local iterations = 1
  if args.iterations then
    assert(type(args.iterations == "number"))
    iterations = args.iterations
    -- setting unused fields to nil to avoid the pollution of 'args' table
    args.iterations = nil
  end
  assert(iterations > 0)

  local split_ratio = 0.8
  if args.split_ratio then
    assert(type(args.split_ratio) == "number")
    assert(args.split_ratio < 1 and args.split_ratio > 0)
    split_ratio = args.split_ratio
    args.split_ratio = nil
  end
    
  local goal_column_index = args.goal_column_index
  assert(goal_column_index)
  args.goal_column_index = nil

  local feature_column_indices
  if args.column_indices then
    assert(type(args.column_indices) == "table")
    feature_column_indices = args.column_indices
    args.column_indices = nil
  end

  for itr = 1, iterations do
    local Train, Test = get_train_test_split(split_ratio, T, feature_column_indices)

    local g_vec_train = Train[goal_column_index]
    Train[goal_column_index] = nil

    local g_vec_test = Test[goal_column_index]
    Test[goal_column_index] = nil

    -- Prepare test table
    local test_sample_count = g_vec_test:length()
    local val, nn_val
    local X = {}
    local expected_predict_value = {}
    local actual_predict_value = {}
    for len = 1, test_sample_count do
      local x = {}
      for _, v in pairs(Test) do
        val, nn_val = v:get_one(len-1)
        x[#x+1] = Scalar.new(val:to_num(), "F4")
      end
      expected_predict_value[len] = g_vec_test:get_one(len-1):to_num()
      X[len] = x
    end
    local result
    local max
    local index
    for i = 1, test_sample_count do
      -- predict for inputs
      result = classify(Train, g_vec_train, X[i], args)
      assert(type(result) == "lVector")
      max, num_val, index = Q.max(result):eval()
      actual_predict_value[i] = index:to_num()
      collectgarbage()
    end
    local acr = get_accuracy(expected_predict_value, actual_predict_value)
    -- print("Accuracy: " .. tostring(acr))
    accuracy[#accuracy + 1] = acr
  end
  return get_average(accuracy), accuracy
end

return run_knn
