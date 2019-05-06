local Q = require 'Q'
local qc = require 'Q/UTILS/lua/q_core'
local run_knn = require 'Q/ML/KNN/lua/run_knn'
local Vector = require 'libvec'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")

local tests = {}
tests.t1 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/occupancy/occupancy.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/occupancy/occupancy_meta.lua"

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.goal = "occupy_status"
  args.is_hdr = true
  local start_time = qc.RDTSC()
  Vector.reset_timers()
  local average_acr, accuracy_table = run_knn(args)
  Vector.print_timers()
  local stop_time = qc.RDTSC()
  print("KNN = ", stop_time-start_time)
  
  print("Accuracy = " .. tostring(average_acr))
  
  print("==============================================")
  if _G['g_time'] then
    for k, v in pairs(_G['g_time']) do
      local niters  = _G['g_ctr'][k] or "unknown"
      local ncycles = tonumber(v)
      print("0," .. k .. "," .. niters .. "," .. ncycles)
    end
  end
  print("==============================================")
end

tests.t2 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.goal = "diagnosis"
  args.is_hdr = true
  local start_time = qc.RDTSC()
  -- Vector.reset_timers()
  local average_acr, accuracy_table = run_knn(args)
  -- Vector.print_timers()
  local stop_time = qc.RDTSC()
  print("KNN = ", stop_time-start_time)

  print("Accuracy = " .. tostring(average_acr))
  --[[
  print("==============================================")
  if _G['g_time'] then
    for k, v in pairs(_G['g_time']) do
      local niters  = _G['g_ctr'][k] or "unknown"
      local ncycles = tonumber(v)
      print("0," .. k .. "," .. niters .. "," .. ncycles)
    end
  end
  print("==============================================")
  ]]
end

return tests
