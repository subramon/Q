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

local function parse_args(args)
  local parsed_args = {}

  parsed_args.meta_data_file	= assert(args.meta_data_file)
  parsed_args.data_file	= args.data_file
  parsed_args.train_csv	= args.train_csv
  parsed_args.test_csv	= args.test_csv
  parsed_args.goal	= assert(args.goal)
  if ( not args.data_file ) then
    assert(args.train_csv)
    assert(args.test_csv)
  else
    assert(args.train_csv == nil)
    assert(args.test_csv == nil)
  end

  local alpha, min_alpha, max_alpha, step_alpha
  if args.alpha then
    alpha = args.alpha
    if type(alpha) ~= "Scalar" then
      alpha = Scalar.new(alpha, "F4")
    end
    min_alpha = alpha
    max_alpha = alpha
    step_alpha = Scalar.new(1.0, "F4")
  else
    min_alpha   = assert(args.min_alpha)
    max_alpha   = assert(args.max_alpha)
    step_alpha  = assert(args.step_alpha)
    if type(min_alpha) ~= "Scalar" then
      min_alpha = Scalar.new(min_alpha, "F4")
    end
    if type(max_alpha) ~= "Scalar" then
      max_alpha = Scalar.new(max_alpha, "F4")
    end
    if type(step_alpha) ~= "Scalar" then
      step_alpha = Scalar.new(step_alpha, "F4")
    end
  end
  parsed_args.min_alpha = min_alpha
  parsed_args.max_alpha = max_alpha
  parsed_args.step_alpha = step_alpha

  local iterations = 1
  if args.iterations then
    assert(type(args.iterations == "number"))
    iterations = args.iterations
  end
  assert(iterations > 0)
  parsed_args.iterations = iterations

  local split_ratio = 0.7
  if args.split_ratio then
    split_ratio = args.split_ratio
  end
  assert(type(split_ratio) == "number")
  assert(split_ratio < 1 and split_ratio > 0)
  parsed_args.split_ratio = split_ratio

  local feature_of_interest
  if args.feature_of_interest then
    assert(type(args.feature_of_interest) == "table")
    feature_of_interest = args.feature_of_interest
  end
  parsed_args.feature_of_interest = feature_of_interest

  return parsed_args
end

local function run_dt(args)
  local parsed_args 	= parse_args(args)

  local meta_data_file  = parsed_args.meta_data_file
  local data_file       = parsed_args.data_file
  local train_csv	= parsed_args.train_csv
  local test_csv	= parsed_args.test_csv
  local goal		= parsed_args.goal
  local min_alpha	= parsed_args.min_alpha
  local max_alpha	= parsed_args.max_alpha
  local step_alpha	= parsed_args.step_alpha
  local iterations	= parsed_args.iterations
  local split_ratio	= parsed_args.split_ratio
  local feature_of_interest = parsed_args.feature_of_interest

  -- load the data
  local T
  if data_file then
    T = Q.load_csv(data_file, dofile(meta_data_file), { is_hdr = args.is_hdr })
  end

  -- start iterating over range of alpha values
  local results = {}
  while min_alpha <= max_alpha do
    -- convert scalar to number for alpha value, avoid extra decimals
    local cur_alpha = utils.round_num(min_alpha:to_num(), 2)
    local metrics = init_metrics()
    for iter = 1, iterations do
      -- break into a training set and a testing set
      local Train, Test
      if T then
        local seed = iter * 100
        Train, Test = split_train_test(T, split_ratio, 
          feature_of_interest, seed)
      else
        -- load data from train & test csv file
        Train = Q.load_csv(train_csv, dofile(meta_data_file),
          { is_hdr = args.is_hdr })
        Test = Q.load_csv(test_csv, dofile(meta_data_file),
          { is_hdr = args.is_hdr })
      end

      local train, g_train, m_train, n_train, train_col_name = 
        extract_goal(Train, goal)

      -- Current implementation assumes 2 values of goal as 0, 1
      local min_g, _ = Q.min(g_train):eval()
      assert(min_g:to_num() == 0)
      local max_g, _ = Q.max(g_train):eval()
      assert(max_g:to_num() == 1)

      -- prepare decision tree model
      local tree = assert(make_dt(train, g_train, min_alpha, 
        args.min_to_split, train_col_name, args.wt_prior))

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
    min_alpha = min_alpha + step_alpha
  end
  return results
end

return run_dt
