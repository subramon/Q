local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
local make_dt = require 'Q/ML/DT/lua/make_dt'
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local JSON = require 'Q/ML/UTILS/lua/JSON'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local check_extract_goal = require 'Q/ML/DT/lua/check_extract_goal'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'
local eval_dt = require 'Q/ML/DT/lua/eval_dt'['eval_dt']
local calc_avg_metrics = require 'Q/ML/DT/lua/eval_dt'['calc_avg_metrics']

local function check_args(args)

  assert(args.M)
  assert(args.O)
  assert(args.goal)
  if ( not args.data_file ) then
    assert(args.train_file)
    assert(args.test_file)
  else
    assert(args.train_file == nil)
    assert(args.test_file == nil)
  end

  assert(type(args.min_alpha) == "number")
  assert(type(args.max_alpha) == "number")
  assert(type(args.step_alpha) == "number")
  assert(args.min_alpha <= args.max_alpha)

  assert(args.step_alpha > 0)

  assert(type(args.min_to_split) == "number")
  assert(args.min_to_split >= 10)

  if ( args.is_goal_real == nil ) then 
    args.is_goal_real = false
  end
  assert(type(args.is_goal_real == "boolean"))

  if ( args.is_goal_real == false ) then 
    assert(type(args.ng) == "number")
    assert(args.ng == 2) --- TODO P4 LIMITATION FOR NOW 
  end

  assert(type(args.iterations) == "number")
  assert(args.iterations >= 1)

  assert(type(args.split_ratio) == "number")
  assert(args.split_ratio < 1 and args.split_ratio > 0)

  if ( args.is_cautious ) then 
    assert(type(args.is_cautious) == "boolean")
  end
  return true
end

local function run_dt(args)
  check_args(args)

  local M  = args.M -- meta data 
  local O  = args.O -- optional global meta data 
  local data_file       = args.data_file
  local goal		= args.goal
  local is_goal_real    = args.is_goal_real
  local iterations	= args.iterations
  local min_alpha	= args.min_alpha
  local min_to_split    = args.min_to_split
  local max_alpha	= args.max_alpha
  local ng              = args.ng
  local split_ratio	= args.split_ratio
  local step_alpha	= args.step_alpha
  local test_file	= args.test_file
  local train_file	= args.train_file
  local wt_prior        = args.wt_prior    

  -- load the data
  local T, Train, Test
  if data_file then
    T = Q.load_csv(data_file, M, O)
    -- eval the data vectors, 
    -- reason for break: evaluating 1 implicitly causes all to be eval'd
    for k, v in pairs(T) do v:eval() break end
    for k, v in pairs(T) do assert(v:eov()) end
  else -- load data from train & test csv file
    -- Note that in this case, we are given the training/testing data
    -- Hence, it does not make sense to do more than one iteration
    -- When there is more than 1 iteration, in each iteration we use
    -- a random number generator to create different train/test data sets
    Train = Q.load_csv(train_file, M, O)
    Test = Q.load_csv(test_file, M, O)
    for k, v in pairs(Train) do v:eval() break end 
    for k, v in pairs(Test)  do v:eval() break end 
    iterations = 1
  end
  -- test print 
  -- S = {} for k, v in pairs(T) do S[#S+1] = v end Q.print_csv(S)

  -- start iterating over range of alpha values
  local results = {}
  local alpha = min_alpha
  local metrics
  while alpha <= max_alpha do
    -- convert scalar to number for alpha value, avoid extra decimals
    for iter = 1, iterations do
      -- break into a training set and a testing set
      if T then
        local seed = iter * 100
        Train, Test = split_train_test(T, split_ratio, seed)
        for k, v in pairs(Train) do v:eval() end
        for k, v in pairs(Train) do assert(v:eov()) end
        for k, v in pairs(Test)  do v:eval() end
        for k, v in pairs(Test)  do assert(v:eov()) end
      end
      -- train is indexed as 1, 2, 3
      -- Train is indexed as foo, bar, ...
      local train, g_train, train_col_names = extract_goal(Train, goal)
      assert(check_extract_goal( train, g_train, ng, is_goal_real, 
        train_col_names))
      -- prepare decision tree model
      local dt_args = {}
      dt_args.ng = ng
      dt_args.is_goal_real = is_goal_real
      dt_args.alpha = alpha 
      dt_args.min_to_split = min_to_split
      dt_args.wt_prior =  wt_prior
      local D = assert(make_dt(train, g_train, train_col_names, dt_args))
      -- print(JSON:encode(D))
  
      -- evaluate model for test samples
      -- TODO P1 metrics = eval_dt(D, Test, goal, ng)

      -- print graphviz
      if args.print_graphviz and iter == 1 then
        local file_name = 
          "graphviz_" .. tostring(alpha) .. "_" .. tostring(iter) .. ".txt"
        export_to_graphviz(file_name, D)
      end
    end
    -- TODO P1 local avg_metrics = calc_avg_metrics(metrics)
    results[alpha] = avg_metrics
    alpha = alpha + step_alpha
  end
  return results
end

return run_dt
