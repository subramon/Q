require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local cVector = require 'libvctr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local Scalar  = require 'libsclr'
local run_dt  = require 'Q/ML/DT/lua/run_dt'
local write_to_csv = require 'Q/ML/DT/lua/write_to_csv'
local qconsts = require 'Q/UTILS/lua/q_consts'

local qc       = require 'Q/UTILS/lua/q_core'
local src_root = qconsts.Q_SRC_ROOT

local tests = {}
tests.t1 = function()
  local dfile = src_root .. "/ML/KNN/data/occupancy/occupancy.csv"
  local mfile = src_root .. "/ML/KNN/data/occupancy/occupancy_meta"
  local ofile = src_root .. "/ML/KNN/data/occupancy/occupancy_opt"

  local args = {}
  args.M = require(mfile); assert(type(args.M) == "table")

  args.O = require(ofile); assert(type(args.O) == "table")
  args.data_file = dfile
  args.goal = "occupy_status"
  args.min_alpha = 0.2
  args.max_alpha = 0.2
  args.wt_prior = 10
  args.step_alpha = 0
  args.iterations = 2
  args.split_ratio = 0.7
  args.print_graphviz = true

  cVector.reset_timers()
  local start_time = qc.RDTSC()
  local results = run_dt(args)
  for alpha, v in pairs(results) do
    for k2, v2 in pairs(v) do
      for k3, v3 in pairs(v2) do
        print(alpha, k2, k3, v3)
      end
    end
  end
  local stop_time = qc.RDTSC()
  write_to_csv(results, "room_occupancy_sample.csv")
  cVector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
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
end

tests.t2 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"
  local alpha = 0.3

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.is_hdr = true
  args.goal = "diagnosis"
  args.alpha = alpha
  args.split_ratio = 0.5
  args.iterations = 2
  args.print_graphviz = true

  -- If you want to provide train and test csv file explicitly,
  -- then don't provide "args.data_file" argument
  --[[
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/b_cancer_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/b_cancer_test.csv"
  ]]
  Vector.reset_timers()
  start_time = qc.RDTSC()
  local results = run_dt(args)
  for alpha, v in pairs(results) do
    for k2, v2 in pairs(v) do
      for k3, v3 in pairs(v2) do
        print(alpha, k2, k3, v3)
      end
    end
  end
  stop_time = qc.RDTSC()
  write_to_csv(results, "cancer_sample.csv")
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
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
end

tests.t3 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_meta.lua"
  local alpha = 0.3

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.is_hdr = true
  args.goal = "Survived"
  args.alpha = alpha
  args.split_ratio = 0.5
  args.iterations = 2
  args.print_graphviz = true

  -- If you want to provide train and test csv file explicitly,
  -- then don't provide "args.data_file" argument
  --[[
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_test.csv"
  ]]

  Vector.reset_timers()
  start_time = qc.RDTSC()
  local results = run_dt(args)
  for alpha, v in pairs(results) do
    for k2, v2 in pairs(v) do
      for k3, v3 in pairs(v2) do
        print(alpha, k2, k3, v3)
      end
    end
  end
  stop_time = qc.RDTSC()
  write_to_csv(results, "titanic_sample.csv")
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
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
end


tests.t4 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"
  local alpha = 0.2

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.is_hdr = true
  args.goal = "class"
  args.alpha = alpha
  args.split_ratio = 0.5
  args.iterations = 2
  args.print_graphviz = true

  -- If you want to provide train and test csv file explicitly,
  -- then don't provide "args.data_file" argument
  --[[
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_test.csv"
  ]]

  Vector.reset_timers()
  start_time = qc.RDTSC()
  local results = run_dt(args)
  for alpha, v in pairs(results) do
    for k2, v2 in pairs(v) do
      for k3, v3 in pairs(v2) do
        print(alpha, k2, k3, v3)
      end
    end
  end
  stop_time = qc.RDTSC()
  write_to_csv(results, "ramesh_category1_sample.csv")
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
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
end

tests.t5 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/Habermans_Survival_Data/after_opr_lifespan.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/Habermans_Survival_Data/lifespan_metadata.lua"
  local alpha = 0.2

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.is_hdr = true
  args.goal = "survival_status"
  args.alpha = alpha
  args.iterations = 2
  args.print_graphviz = true

  Vector.reset_timers()
  start_time = qc.RDTSC()
  local results = run_dt(args)
  for alpha, v in pairs(results) do
    for k2, v2 in pairs(v) do
      for k3, v3 in pairs(v2) do
        print(alpha, k2, k3, v3)
      end
    end
  end
  stop_time = qc.RDTSC()
  write_to_csv(results, "habermans_sample.csv")
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
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
end

tests.t6 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/Habermans_Survival_Data/after_opr_lifespan.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/Habermans_Survival_Data/lifespan_metadata.lua"
  local split = require 'Q/ML/UTILS/lua/split_csv_to_train_test'
  local split_csv_args = {}
  split_csv_args.is_hdr = true
  local hdr_info = "age,yop,no_of_pos_axillary_nodes,survival_status"  

  split(data_file, metadata_file, split_csv_args, hdr_info)

  local alpha = 0.2
  -- If you want to provide train and test csv file explicitly,
  -- then don't provide "args.data_file" argument
  local args = {}
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/Habermans_Survival_Data/after_opr_lifespan_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/Habermans_Survival_Data/after_opr_lifespan_test.csv"
  args.meta_data_file = metadata_file
  args.is_hdr = true
  args.goal = "survival_status"
  args.alpha = alpha
  args.iterations = 2
  args.print_graphviz = true

  Vector.reset_timers()
  start_time = qc.RDTSC()
  local results = run_dt(args)
  for alpha, v in pairs(results) do
    for k2, v2 in pairs(v) do
      for k3, v3 in pairs(v2) do
        print(alpha, k2, k3, v3)
      end
    end
  end
  stop_time = qc.RDTSC()
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
end

-- return tests
tests.t1()
