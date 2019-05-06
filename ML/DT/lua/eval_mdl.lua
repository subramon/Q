local check_dt = require 'Q/ML/DT/lua/dt'['check_dt']
local predict = require 'Q/ML/DT/lua/dt'['predict']
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local utils = require 'Q/UTILS/lua/utils'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local evaluate_dt = require 'Q/ML/DT/lua/evaluate_dt'['evaluate_dt']
local preprocess_dt = require 'Q/ML/DT/lua/dt'['preprocess_dt']

local fns = {}
local metrics_of_interest = 
{'accuracy', 'precision', 'recall', 'f1_score', 'mcc', 'payout'}


local function init_metrics()
  local metrics = {}
  for i, v in pairs(metrics_of_interest) do
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

local function do_predict(tree, Test, goal)
  local predicted_values = {}
  local actual_values    = {}

  -- extract goal vector
  local test,  g_test,  m_test,  n_test, test_col_name  =
    extract_goal(Test,  goal)

  -- predict for test samples
  local TAILS = 0
  local HEADS = 1
  for i = 1, n_test do
    local x = {}
    for k = 1, m_test do
      x[k] = test[k]:get_one(i-1):to_num()
    end
    local actual_val = g_test:get_one(i-1):to_num()
    local n_H, n_T = predict(tree, x, actual_val)
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

local function eval_mdl(tree, Test, goal, metrics)
  if not metrics then
    metrics = init_metrics()
  end
  local predicted_values = {}
  local actual_values    = {}

  -- verify DT
  check_dt(tree)

  -- preprocess the tree
  preprocess_dt(tree)  -- initializes nh1 and nt1 to zero at leaf nodes

  -- perform prediction
  local predicted_values, actual_values = do_predict(tree, Test, goal)

  -- prepare output metrics table
  local iter = #metrics.payout+1
  local report = ml_utils.classification_report(
    actual_values, predicted_values)    -- get classification_report
  report.payout = evaluate_dt(tree)     -- calculate payout
  for i, v in pairs(metrics_of_interest) do
    metrics[v][iter] = report[v]
  end

  return metrics
end

fns.eval_mdl = eval_mdl
fns.init_metrics = init_metrics
fns.calc_avg_metrics = calc_avg_metrics
fns.do_predict = do_predict

return fns 
