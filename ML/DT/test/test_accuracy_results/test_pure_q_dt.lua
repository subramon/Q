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
  --[[
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"

  local split = require 'Q/ML/UTILS/lua/split_csv_to_train_test'
  local split_csv_args = {}
  split_csv_args.is_hdr = true
  split_csv_args.split_ratio = 0.5
  local hdr_info = "id,diagnosis,radius_mean,texture_mean,perimeter_mean,area_mean,smoothness_mean,compactness_mean,concavity_mean,concave points_mean,symmetry_mean,fractal_dimension_mean,radius_se,texture_se,perimeter_se,area_se,smoothness_se,compactness_se,concavity_se,concave points_se,symmetry_se,fractal_dimension_se,radius_worst,texture_worst,perimeter_worst,area_worst,smoothness_worst,compactness_worst,concavity_worst,concave points_worst,symmetry_worst,fractal_dimension_worst"
  -- splitting data into 50-50 train test
  split(data_file, metadata_file, split_csv_args, hdr_info)
  --]]
  local args = {}
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data_test.csv"
  args.is_hdr = true
  args.goal = "diagnosis"
  args.iterations = 1
  args.min_alpha = 0.1
  args.max_alpha = 0.8
  args.step_alpha = 0.01
  args.is_hdr = true

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = run_dt(args)
  local csv_path = "b_cancer_pure_q_results.csv"

  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)

  --[[
  local accuracy = result['accuracy']
  local accuracy_std_deviation = result['accuracy_std_deviation']
  local gain = result['gain']
  local gain_std_deviation = result['gain_std_deviation']
  local cost = result['cost']
  local cost_std_deviation = result['cost_std_deviation']
  local precision = result['precision']
  local precision_std_deviation = result['precision_std_deviation']
  local recall = result['recall']
  local recall_std_deviation = result['recall_std_deviation']
  local f1_score = result['f1_score']
  local f1_score_std_deviation = result['f1_score_std_deviation']


  stop_time = qc.RDTSC()
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
  ]]
  --[[
  if _G['g_time'] then
    for k, v in pairs(_G['g_time']) do
      local niters  = _G['g_ctr'][k] or "unknown"
      local ncycles = tonumber(v)
      print("0," .. k .. "," .. niters .. "," .. ncycles)
    end
  end
  print("================================================")
  ]]

  --[[
  print("alpha & gain table")
  for i, v in tablex.sort(gain) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost table")
  for i, v in tablex.sort(cost) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy table")
  for i, v in tablex.sort(accuracy) do
    print(i, v)
  end
  print("================================================")
  print("alpha & precision table")
  for i, v in tablex.sort(precision) do
    print(i, v)
  end
  print("================================================")
  print("alpha & recall table")
  for i, v in tablex.sort(recall) do
    print(i, v)
  end
  print("================================================")
  print("alpha & f1_score table")
  for i, v in tablex.sort(f1_score) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy_std_deviation table")
  for i, v in tablex.sort(accuracy_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & gain_std_deviation table")
  for i, v in tablex.sort(gain_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost_std_deviation table")
  for i, v in tablex.sort(cost_std_deviation) do
    print(i, v)
  end
  print("================================================")
  ]]
end

tests.t2 = function()
  -- Test alpha calculation
  --[[
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_meta.lua"

  local split = require 'Q/ML/UTILS/lua/split_csv_to_train_test'
  local split_csv_args = {}
  split_csv_args.is_hdr = true
  split_csv_args.split_ratio = 0.5
  local hdr_info = "PassengerId,Survived,Pclass,Sex,Age,SibSp,Parch,Fare,Embarked"
  -- splitting data into 50-50 train test
  split(data_file, metadata_file, split_csv_args, hdr_info)
  --]]
  local args = {}
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_meta.lua"
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_test.csv"
  args.is_hdr = true
  args.goal = "Survived"
  args.iterations = 1
  args.min_alpha = 0.1
  args.max_alpha = 0.8
  args.step_alpha = 0.01
  args.is_hdr = true

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = run_dt(args)
  local csv_path = "titanic_pure_q_results.csv"

  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)

end


tests.t3 = function()
  -- Test alpha calculation
  --[[
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"

  local split = require 'Q/ML/UTILS/lua/split_csv_to_train_test'
  local split_csv_args = {}
  split_csv_args.is_hdr = true
  split_csv_args.split_ratio = 0.5
  local hdr_info = "f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16,f17,class"
  -- splitting data into 50-50 train test
  split(data_file, metadata_file, split_csv_args, hdr_info)
  --]]
  local args = {}
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_test.csv"
  args.is_hdr = true
  args.goal = "class"
  args.iterations = 1
  args.min_alpha = 0.1
  args.max_alpha = 0.8
  args.step_alpha = 0.01
  args.is_hdr = true

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = run_dt(args)
  local csv_path = "from_ramesh_category1_pure_q_results.csv"

  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)

end

tests.t4 = function()
  -- Test alpha calculation
  --[[
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"

  local split = require 'Q/ML/UTILS/lua/split_csv_to_train_test'
  local split_csv_args = {}
  split_csv_args.is_hdr = true
  split_csv_args.split_ratio = 0.5
  local hdr_info = "f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16,f17,class"
  -- splitting data into 50-50 train test
  split(data_file, metadata_file, split_csv_args, hdr_info)
  --]]
  local args = {}
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds2_11720_7137_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds2_11720_7137_test.csv"
  args.is_hdr = true
  args.goal = "class"
  args.iterations = 1
  args.min_alpha = 0.1
  args.max_alpha = 0.8
  args.step_alpha = 0.01
  args.is_hdr = true

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = run_dt(args)
  local csv_path = "from_ramesh_category2_pure_q_results.csv"

  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)

end

return tests
