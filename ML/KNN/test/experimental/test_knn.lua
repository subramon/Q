local Q = require 'Q'
local classify = require 'Q/ML/KNN/lua/classify'
local utils = require 'Q/UTILS/lua/utils'
local Scalar = require 'libsclr'
local tests = {}

tests.t1 = function()
  local n = 2
  local m = 4
  local g_vec        -- it's size will be n
  local x            -- input sample of length m, it is not vector
  local alpha        -- it's length is m, it is not vector
  
  local train_vec

  local T = {}
  for i = 1, m do
    T[i] = Q.mk_col({2, 4}, "F4")
  end

  g_vec = Q.mk_col({0, 1}, "I4")

  local x_val = Scalar.new(3, "F4")
  x = {x_val, x_val, x_val, x_val}

  local alpha_val = Scalar.new(1, "F4")
  alpha = {alpha_val, alpha_val, alpha_val, alpha_val}

  local exp = Scalar.new(2, "F4")

  local result = classify(T, g_vec, x, exp, alpha)
  assert(type(result) == "lVector")
  Q.print_csv(result)
end

--[[
tests.t2 = function()
  -- TODO: Add load code for iris_flower data
  -- Load the iris flower data
  local saved_file = os.getenv("Q_METADATA_DIR") .. "/iris_flower.saved"
  dofile(saved_file)

  local g_vec = T['flower_type']

  -- Remove 'flower_type' from table
  T['flower_type'] = nil

  -- predict_input {5.5, 2.3, 4.0, 1.3}, prediction result = 1 i.e of type "Iris-versicolor" 
  local x = {Scalar.new(5.5, "F4"), Scalar.new(2.3, "F4"), Scalar.new(4.0, "F4"), Scalar.new(1.3, "F4")}

  local alpha_val = Scalar.new(1, "F4")
  alpha = {alpha_val, alpha_val, alpha_val, alpha_val}

  local exp = Scalar.new(2, "F4")

  local result = classify(T, g_vec, x, exp, alpha)
  assert(type(result) == "lVector")
  Q.print_csv(result)
  print("completed t2 successfully")
end
]]

tests.t3 = function()
  -- TODO: add load code for room_occupancy data
  -- Load room_occupancy data
  local load_room_occupancy_data = require 'Q/ML/KNN/load_data/load_room_occupancy_data'

  -- T needs to be global
  T = load_room_occupancy_data()

  local g_vec = T['occupy_status']

  -- Remove 'occupy_status' from table
  T['occupy_status'] = nil

  -- predict_input {1.643221, 0.281781, -0.613726, 0.004625, 0.797606}, prediction result = 0
  local x = {Scalar.new(1.643221, "F4"), Scalar.new(0.281781, "F4"), Scalar.new(-0.613726, "F4"), Scalar.new(0.004625, "F4"), Scalar.new(0.797606, "F4")}

  local alpha_val = Scalar.new(1, "F4")
  alpha = {alpha_val, alpha_val, alpha_val, alpha_val, alpha_val}

  local exp = Scalar.new(2, "F4")

  local result = classify(T, g_vec, x, exp, alpha)
  assert(type(result) == "lVector")
  local max = Q.max(result):eval():to_num()
  local index = utils.get_index(result, max)
  print(max, index)
  print("completed t3 successfully")
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

--[[
tests.t4 = function()
  -- TODO: add load code for room_occupancy data
  -- Load room_occupancy_train data
  local saved_file = os.getenv("Q_METADATA_DIR") .. "/room_occupancy_train.saved"
  dofile(saved_file)

  local g_vec_train = T_train['occupy_status']

  -- Remove 'occupy_status' from table
  T_train['occupy_status'] = nil

  -- Load room_occupancy_test data
  saved_file = os.getenv("Q_METADATA_DIR") .. "/room_occupancy_test.saved"
  dofile(saved_file)

  local g_vec_test = T_test['occupy_status']

  -- Remove 'occupy_status' from table
  T_test['occupy_status'] = nil

  local test_sample_count = g_vec_test:length()

  -- prepate test_table
  local val, nn_val
  local X = {}
  local expected_predict_value = {}
  local actual_predict_value = {}
  for len = 1, test_sample_count do
    local x = {}
    for i, v in pairs(T_test) do
      val, nn_val = v:get_one(len-1)
      x[#x+1] = Scalar.new(val:to_num(), "F4")
    end
    expected_predict_value[len] = g_vec_test:get_one(len-1):to_num()
    X[len] = x
  end

  local alpha_val = Scalar.new(1, "F4")
  alpha = {alpha_val, alpha_val, alpha_val, alpha_val, alpha_val}
  local exp = Scalar.new(2, "F4")
  local result
  local max
  local index
  for i = 1, test_sample_count do
    -- predict_input
    result = classify(T_train, g_vec_train, X[i], exp, alpha)
    assert(type(result) == "lVector")
    max = Q.max(result):eval():to_num()
    index = utils.get_index(result, max)
    actual_predict_value[i] = index
  end
  local accuracy = get_accuracy(expected_predict_value, actual_predict_value)
  print("Accuracy = ", accuracy)
  print("completed t4 successfully")
end
]]

tests.t5 = function()
  -- Tests the run_knn function
  local run_knn = require 'Q/ML/KNN/lua/run_knn'
  local load_room_occupancy_data = require 'Q/ML/KNN/load_data/load_room_occupancy_data'

  -- T needs to be global
  T = load_room_occupancy_data()

  local alpha_val = Scalar.new(1, "F4")
  alpha = {alpha_val, alpha_val, alpha_val, alpha_val, alpha_val}
  local exponent = Scalar.new(2, "F4")
  local goal_column_index = "occupy_status"

  local args = {iterations = 1, split_ratio = 0.7, alpha = alpha, exponent = exponent, goal_column_index = goal_column_index}

  local avg_accuracy, accuracy_table = run_knn(args)
  print("====================================")
  if _G['g_time'] then
    for i, v in pairs(_G['g_time']) do
      print(i, tostring(tonumber(v)))
    end
  end

  print("Average: ", avg_accuracy)
  for i, v in pairs(accuracy_table) do
    print(i, v)
  end
end

return tests
