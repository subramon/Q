local Q = require 'Q'
local qc = require 'Q/UTILS/lua/q_core'
local plpath = require 'pl.path'
local run_voting = require 'Q/ML/KNN/lua/run_voting'
-- local utils = require 'Q/UTILS/lua/utils'
local tests = {}

local q_src_root = os.getenv("Q_SRC_ROOT")
assert(plpath.isdir(q_src_root))
local data_dir = q_src_root .. "/ML/KNN/data/"
assert(plpath.isdir(data_dir))

tests.t1 = function()
  local implementations = { "C", "Lua", "Lua_basic"}
  for _, implementation in ipairs(implementations) do 
    inputs = {
      meta_data_file = data_dir .. "/occupancy/occupancy_meta.lua",
      data_file      = data_dir .. "/occupancy/occupancy.csv",
      split_ratio    = 0.8,
      goal           = "occupy_status",
      implementation       = implementation
    }

    local t_start = qc.get_time_usec()
    ret_vals = run_voting(inputs)
    local t_stop = qc.get_time_usec()
    print("implementation = ", implementation,t_stop - t_start)
    print("accuracy       = ", ret_vals.accuracy)
    -- for k, v in pairs(ret_vals) do print(k, v) end 
  end
  print("Test t1 completed")
end
tests.t1(); os.exit()
return tests
