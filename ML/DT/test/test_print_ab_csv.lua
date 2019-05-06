local Q = require 'Q'
local Vector = require 'libvec'
local Scalar = require 'libsclr'
local run_dt = require 'Q/ML/DT/lua/run_dt'
local make_dt = require 'Q/ML/DT/lua/dt'['make_dt']
local check_dt = require 'Q/ML/DT/lua/dt'['check_dt']
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local print_ab_csv = require 'Q/ML/DT/lua/print_ab_csv'['print_ab_csv']
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local path_to_here = Q_SRC_ROOT .. "/ML/DT/test/"
local tests = {}

tests.t1 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data.csv"
  local meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"
  local alpha = Scalar.new(0.3, "F4")

  local is_hdr = true
  local goal = "diagnosis"
  local split_ratio = 0.5

  local T = Q.load_csv(data_file, dofile(meta_data_file), { is_hdr = is_hdr })

  local Train, Test = split_train_test(T, split_ratio, nil, 100)

  local train, g_train, m_train, n_train, train_col_name = extract_goal(Train, goal)
  --local test,  g_test,  m_test,  n_test, test_col_name  = extract_goal(Test,  goal)

  -- Current implementation assumes 2 values of goal as 0, 1
  local min_g, _ = Q.min(g_train):eval()
  assert(min_g:to_num() == 0)
  local max_g, _ = Q.max(g_train):eval()
  assert(max_g:to_num() == 1)

  local predicted_values = {}
  local actual_values = {}
  -- prepare decision tree
  local  tree = make_dt(train, g_train, alpha, 10, train_col_name)
  assert(tree)

  -- verify the decision tree
  check_dt(tree)

  -- print decision tree in csv format
  local model_idx = 0
  local tree_idx  = 0
  local gb_val    = 0
  local csv_file_name = print_ab_csv(tree, model_idx, tree_idx, gb_val)
  assert(csv_file_name)
end

return tests
