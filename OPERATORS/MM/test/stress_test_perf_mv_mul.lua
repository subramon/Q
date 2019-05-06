-- PERFORMANCE 
local Q = require 'Q'
local Vector = require 'libvec'
require 'Q/UTILS/lua/strict'
local qc = require 'Q/UTILS/lua/q_core'
local utils = require 'Q/UTILS/lua/utils'

local tests = {}
tests.t1 = function(
  num_iters
  )
  local start_time = qc.RDTSC()
  local n = 16*1048576 -- number of rows
  local m = 1024 -- number of columns
  local modes = { "opt", "simple" }
  for _, mode in pairs(modes) do 
    local X = {}
    for i = 1, m do 
      X[i] = Q.const({val  = 1, len = n, qtype = "F8"}):memo(false)
    end
    local Y = Q.const({val  = 1, len = m, qtype = "F8"}):eval()
    _G['g_time'] = {}
    Vector.reset_timers()
    local t_start = tonumber(qc.RDTSC())
    local Z = Q.mv_mul(X, Y, { mode = mode}):eval()
    local t_stop = tonumber(qc.RDTSC())
    Vector.print_timers()
    local time = ( t_stop - t_start ) 
    print(mode, time, time / (2500.0 * 1000000.0 ))
    -- Q.print_csv(Z)
    if _G['g_time'] then
      for k, v in pairs(_G['g_time']) do
        local niters  = _G['g_ctr'][k] or "unknown"
        local ncycles = tonumber(v)
        print("0," .. k .. "," .. niters .. "," .. ncycles)
      end
    end
    print("=====================================")
  end
  local stop_time = qc.RDTSC()
  print("stress_test_perf_mv_mul time(seconds): ", utils["RDTSC"](stop_time-start_time))
  print("Successfully completed stress test OPERATORS/MM/test/stress_test_perf_mv_mul.lua")
end
-- tests.t1()
return tests
