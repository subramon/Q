local Q = require 'Q'
local qc = require 'Q/UTILS/lua/q_core'
local Vector = require 'libvec'
local tablex = require 'pl.tablex'
local run_dt = require 'Q/ML/DT/lua/run_dt'
local write_to_csv = require 'Q/ML/DT/lua/write_to_csv'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")

local tests = {}

tests.t1 = function()
  -- Test alpha calculation
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_meta.lua"

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.is_hdr = true
  args.goal = "Survived"
  args.iterations = 10
  args.min_alpha = 0.15
  args.max_alpha = 0.7
  args.step_alpha = 0.1
  args.split_ratio = 0.5
  args.is_hdr = true

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = run_dt(args)
  local csv_path = "titanic_results.csv"

  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)
end

tests.t2 = function()
  -- Test alpha calculation
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.is_hdr = true
  args.goal = "class"
  args.iterations = 10
  args.min_alpha = 0.15
  args.max_alpha = 0.7
  args.step_alpha = 0.1
  args.split_ratio = 0.5
  args.is_hdr = true

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = run_dt(args)
  local csv_path = "ramesh's_dataset_results.csv"

  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)
end


tests.t3 = function()
  -- Test alpha calculation
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"


  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.is_hdr = true
  args.goal = "diagnosis"
  args.iterations = 2
  args.min_alpha = 0.15
  args.max_alpha = 0.7
  args.step_alpha = 0.1
  args.split_ratio = 0.5
  args.is_hdr = true

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = run_dt(args)
  local csv_path = "b_cancer_results.csv"

  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)
end

return tests
