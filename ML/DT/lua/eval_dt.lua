local check_dt = require 'Q/ML/DT/lua/dt'['check_dt']
local find_leaf_stats = require 'Q/ML/DT/lua/dt'['find_leaf_stats']
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local utils = require 'Q/UTILS/lua/utils'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local check_extract_goal = require 'Q/ML/DT/lua/check_extract_goal'
local payout_for_dt = require 'Q/ML/DT/lua/payout_for_dt'
local init_leaf_heads_tails = require 'Q/ML/DT/lua/dt'['init_leaf_heads_tails']

local fns = {}
local metrics_of_interest = 
{'accuracy', 'precision', 'recall', 'f1_score', 'mcc', 'payout'}


local function init_metrics()
  local metrics = {}
  for _, v in pairs(metrics_of_interest) do
    metrics[v] = {}
  end
  return metrics
end

local function calc_avg_metrics(metrics)
  local out_metrics = {}
  -- calculate avg and standard deviation for each metric
  for k, v in pairs(metrics) do
    out_metrics[k] = {}
    out_metrics[k].avg = utils.round_num(ml_utils.average_score(v), 4)
    out_metrics[k].sd  = utils.round_num(ml_utils.std_deviation_score(v), 4)
  end
  return out_metrics
end

local function do_predict(D, Test, goal, ng)
  local predicted_values = {}
  local actual_values    = {}

  -- extract goal vector
  local test, g_test, test_col_names  = extract_goal(Test,  goal)
  assert(check_extract_goal(test, g_test, ng, test_col_names))

  -- TODO: P2 Two improvements to be made
  -- (1) vectorize
  -- (2) use something better than just majority
  -- predict for test samples
  local TAILS = 0
  local HEADS = 1
  local num_rows = g_test:length()
  local num_cols = #test
  for i = 1, num_rows do
    local x = {}
    for k = 1, num_cols do
      x[k] = test[k]:get1(i-1):to_num()
    end
    local actual_val = g_test:get1(i-1):to_num()
    local n_H, n_T = find_leaf_stats(D, x, actual_val)
    local decision
    if n_H > n_T then
      decision = HEADS
    else
      decision = TAILS
    end
    predicted_values[i] = decision
    actual_values[i]    = actual_val
  end

  return predicted_values, actual_values
end

local function eval_dt(D, Test, goal, ng)
  local metrics = init_metrics()
  local predicted_values = {}
  local actual_values    = {}

  assert(check_dt(D)) -- verify DT
  -- initializes n_H_test/n_T_test to zero at leaf nodes
  init_leaf_heads_tails(D)  
  -- perform prediction
  local predicted_values, actual_values = do_predict(D, Test, goal, ng)
  -- prepare output metrics table
  local iter = #metrics.payout+1
  -- get classification_report
  local report = ml_utils.classification_report(
    actual_values, predicted_values)    
  report.payout = payout_for_dt(D)     -- calculate payout
  for _, v in pairs(metrics_of_interest) do
    metrics[v][iter] = report[v]
  end
  -- TODO P1 Need to understand above better

  return metrics
end

fns.eval_dt = eval_dt
fns.init_metrics = init_metrics
fns.calc_avg_metrics = calc_avg_metrics
fns.do_predict = do_predict

return fns 
