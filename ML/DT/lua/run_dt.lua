local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'
local make_dt = require 'Q/ML/DT/lua/dt'['make_dt']
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'
local eval_mdl = require 'Q/ML/DT/lua/eval_mdl'['eval_mdl']
local init_metrics = require 'Q/ML/DT/lua/eval_mdl'['init_metrics']
local calc_avg_metrics = require 'Q/ML/DT/lua/eval_mdl'['calc_avg_metrics']

local function check_args(args)

  assert(args.M)
  assert(args.O)
  assert(args.goal)
  if ( not args.data_file ) then
    assert(args.train_csv)
    assert(args.test_csv)
  else
    assert(args.train_csv == nil)
    assert(args.test_csv == nil)
  end

  assert(type(args.min_alpha) == "number")
  assert(type(args.max_alpha) == "number")
  assert(type(args.step_alpha) == "number")
  assert(args.min_alpha <= args.max_alpha)

  assert(args.step_alpha >= 0)
  if ( args.min_alpha < args.max_alpha ) then
    assert(args.step_alpha > 0)
  end

  assert(type(args.iterations) == "number")
  assert(args.iterations >= 1)

  assert(type(args.split_ratio) == "number")
  assert(args.split_ratio < 1 and args.split_ratio > 0)

  return true
end

local function run_dt(args)
  check_args(args)

  local M  = args.M -- meta data 
  local O  = args.O -- optional global meta data 
  local data_file       = args.data_file
  local train_csv	= args.train_csv
  local test_csv	= args.test_csv
  local goal		= args.goal
  local min_alpha	= args.min_alpha
  local max_alpha	= args.max_alpha
  local step_alpha	= args.step_alpha
  local iterations	= args.iterations
  local split_ratio	= args.split_ratio

  -- load the data
  local T
  if data_file then
    print(data_file)
    T = Q.load_csv(data_file, M, O)
  end
  -- eval the vectors
  for k, v in pairs(T) do v:eval() break end
  -- test print 
  -- S = {} for k, v in pairs(T) do S[#S+1] = v end Q.print_csv(S)

  -- start iterating over range of alpha values
  local results = {}
  local alpha = min_alpha
  while alpha <= max_alpha do
    -- convert scalar to number for alpha value, avoid extra decimals
    print(alpha)
    local metrics = init_metrics()
    for iter = 1, iterations do
      -- break into a training set and a testing set
      local Train, Test
      if T then
        local seed = iter * 100
        Train, Test = split_train_test(T, split_ratio, seed)
      else
        -- load data from train & test csv file
        Train = Q.load_csv(train_csv, M, O)
        Test = Q.load_csv(test_csv, M, O)
      end
      for k, v in pairs(Train) do v:eval() end 
      for k, v in pairs(Test)  do v:eval() end 

      local train, g_train, train_col_names = extract_goal(Train, goal)

      -- Current implementation assumes 2 values of goal as 0, 1
      local min_g, _ = Q.min(g_train):eval()
      assert(min_g:to_num() == 0)
      local max_g, _ = Q.max(g_train):eval()
      assert(max_g:to_num() == 1)

      -- prepare decision tree model
      local tree = assert(make_dt(train, g_train, min_alpha, 
        args.min_to_split, train_col_names, args.wt_prior))

      -- evaluate model for test samples
      metrics = eval_mdl(tree, Test, goal, metrics)

      -- print graphviz
      if args.print_graphviz and iter == 1 then
        local file_name = tostring(cur_alpha) .. "_" .. tostring(iter) .. "_graphviz.txt"
        export_to_graphviz(file_name, tree)
      end
    end
    local avg_metrics = calc_avg_metrics(metrics)
    results[cur_alpha] = avg_metrics
    alpha = alpha + step_alpha
  end
  return results
end

return run_dt
