local std_deviation_score = require 'Q/ML/UTILS/lua/ml_utils'['std_deviation_score']
local accuracy_score = require 'Q/ML/UTILS/lua/ml_utils'['accuracy_score']
local precision_score = require 'Q/ML/UTILS/lua/ml_utils'['precision_score']
local recall_score = require 'Q/ML/UTILS/lua/ml_utils'['recall_score']
local f1_score = require 'Q/ML/UTILS/lua/ml_utils'['f1_score']
local confusion_matrix = require 'Q/ML/UTILS/lua/ml_utils'['confusion_matrix']

local tests = {}

tests.t1 = function()
  -- std deviation test
  local in_list = {2, 4, 6, 8, 10, 12}
  local exp_result = 3.4156502553199
  local std_deviation = std_deviation_score(in_list)
  assert(tostring(std_deviation) == tostring(exp_result))
  print("completed test t1")
end

tests.t2 = function()
  -- accuracy score test
  local actual_val = { 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0 }
  local predicated_val = { 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0 }
  local exp_result = 56.25
  local accuracy = accuracy_score(actual_val, predicated_val)
  assert(accuracy == exp_result)
  print("completed test t2")
end

tests.t3 = function()
  -- accuracy score test
  local actual_val = { 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0 }
  local predicated_val = { 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0 }
  local exp_result = { TP = 4, FN = 4, FP = 3, TN = 5 }
  local conf_matrix = confusion_matrix(actual_val, predicated_val)
  for i, v in pairs(conf_matrix) do
    assert(v == exp_result[i])
  end
  print("completed test t3")
end

tests.t4 = function()
  -- precision score test
  local actual_val = { 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0 }
  local predicated_val = { 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0 }
  local exp_result = 0.5714285714285714
  local precision = precision_score(actual_val, predicated_val)
  assert(precision == exp_result)
  print("completed test t4")
end

tests.t5 = function()
  -- recall score test
  local actual_val = { 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0 }
  local predicated_val = { 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0 }
  local exp_result = 0.5
  local recall = recall_score(actual_val, predicated_val)
  assert(recall == exp_result)
  print("completed test t5")
end

tests.t6 = function()
  -- f1 score test
  local actual_val = { 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0 }
  local predicated_val = { 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0 }
  local exp_result = 0.53333333333333
  local f1 = f1_score(actual_val, predicated_val)
  assert(tostring(f1) == tostring(exp_result))
  print("completed test t6")
end

return tests

