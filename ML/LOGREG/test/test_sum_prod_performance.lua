local Q = require 'Q'
local qc        = require 'Q/UTILS/lua/q_core'
local Vector = require 'libvec'

local test = {}

test.t1 = function ()
  local sum_prod = require 'Q/ML/LOGREG/lua/sum_prod_eval'
  local N = 256 * 65536
  local M = 16
  local X = {}

  for i = 1, M do
    X[i] = Q.rand({lb = 0, ub = 10, qtype = "F4", len = N}):eval()
  end

  local w = Q.rand({lb = 0, ub = 1, qtype = "F4", len = N}):eval()

  local start_time = qc.RDTSC()
  Vector.reset_timers()
  local A = sum_prod(X, w)
  Vector.print_timers()
  local stop_time = qc.RDTSC()
  print("sum_prod eval = ", stop_time-start_time)
  --[[
  for i = 1, 3 do
    for j = 1, 3 do
      print(A[i][j])
    end
    print("================")
  end
  ]]

  print("==============================================")
  if _G['g_time'] then
    for k, v in pairs(_G['g_time']) do
      local niters  = _G['g_ctr'][k] or "unknown"
      local ncycles = tonumber(v)
      print("0," .. k .. "," .. niters .. "," .. ncycles)
    end
  end


  print("SUCCESS")
  os.exit()
end

test.t2 = function ()
  local sum_prod = require 'Q/ML/LOGREG/lua/sum_prod_chunk'
  local N = 256 * 65536
  local M = 16
  local X = {}

  for i = 1, M do
    X[i] = Q.rand({lb = 0, ub = 10, qtype = "F4", len = N}):eval()
  end

  local w = Q.rand({lb = 0, ub = 1, qtype = "F4", len = N}):eval()

  local start_time = qc.RDTSC()
  Vector.reset_timers()
  local A = sum_prod(X, w)
  Vector.print_timers()
  local stop_time = qc.RDTSC()
  print("sum_prod chunk = ", stop_time-start_time)
  --[[
  for i = 1, 3 do
    for j = 1, 3 do
      print(A[i][j])
    end
    print("================")
  end
  ]]

  print("==============================================")
  if _G['g_time'] then
    for k, v in pairs(_G['g_time']) do
      local niters  = _G['g_ctr'][k] or "unknown"
      local ncycles = tonumber(v)
      print("0," .. k .. "," .. niters .. "," .. ncycles)
    end
  end

  print("SUCCESS")
  os.exit()
end
return test
