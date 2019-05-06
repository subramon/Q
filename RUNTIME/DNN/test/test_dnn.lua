local Q = require 'Q'
local ldnn = require 'Q/RUNTIME/DNN/lua/ldnn'
local qc = require 'Q/UTILS/lua/q_core'
local Scalar = require 'libsclr'
require 'Q/UTILS/lua/strict'

local tests = {}
Xin = {}
Xout = {}
npl = {}
dpl = {}
afns = {}
tests.t1 = function(batch_size)
  local batch_size = batch_size or 4096
  local saved_file_path = "dnn_in.txt"
  local n_samples = 1024 * 1024
  print("batch size = ", batch_size)

--[[
  npl = { 128, 64, 32, 8, 4, 2, 1 }
  dpl = { 0, 0, 0, 0, 0, 0, 0 }
  afns = { '', 'relu', 'relu', 'relu', 'relu', 'relu', 'sigmoid' }
  for i = 1, npl[1] do
    Xin[i] = Q.rand( { lb = -2, ub = 2, seed = 1234, qtype = "F4", len = n_samples }):eval()
  end
  Xout[1] = Q.convert(Q.rand( { lb = 0, ub = 2, seed = 1234, qtype = "I1", len = n_samples }), "F4"):eval()
  Q.save(saved_file_path)
  os.exit()
--]]
  -- For the first time, enable the above code block and then onwards just restore it
  Q.restore(saved_file_path)

  print("Network structure")
  print("n_layers = " .. #npl)
  local npl_str = ''
  for i, v in pairs(npl) do
    npl_str = npl_str .. "-" .. tostring(v)
  end
  print("structure = " .. npl_str)
  local start_t = qc.RDTSC()
  local x = ldnn.new({ npl = npl, dpl = dpl, activation_functions = afns} )
  local end_t = qc.RDTSC()
  print("dnn_new = " .. tonumber(end_t - start_t))
  -- assert(x:check())

  start_t = qc.RDTSC()
  x:set_io(Xin, Xout)
  end_t = qc.RDTSC()
  print("set_io = " .. tonumber(end_t - start_t))

  start_t = qc.RDTSC()
  x:set_batch_size(batch_size)
  end_t = qc.RDTSC()
  print("set_batch = " .. tonumber(end_t - start_t))

  print("training started")
  start_t = qc.RDTSC()
  x:fit(1)
  end_t = qc.RDTSC()
  print("fit = " .. tonumber(end_t - start_t))
  print("Test t4 succeeded")
end

tests.t2 = function()
  local batch_size = 1
  npl = { 8, 4, 2, 1 }
  dpl = { 0, 0, 0, 0 }
  afns = { '', 'relu', 'relu', 'sigmoid' }

  print("Network structure")
  print("n_layers = " .. #npl)
  local npl_str = ''
  for i, v in pairs(npl) do
    npl_str = npl_str .. "-" .. tostring(v)
  end
  print("structure = " .. npl_str)
  local start_t = qc.RDTSC()
  local x = ldnn.new({ npl = npl, dpl = dpl, activation_functions = afns} )
  local end_t = qc.RDTSC()
  print("dnn_new = " .. tonumber(end_t - start_t))

  --[[
  start_t = qc.RDTSC()
  x:set_io_predict(Xin)
  end_t = qc.RDTSC()
  print("set_io = " .. tostring(end_t - start_t))
  ]]

  start_t = qc.RDTSC()
  x:set_batch_size(batch_size)
  end_t = qc.RDTSC()
  print("set_batch = " .. tonumber(end_t - start_t))

  print("testing started")
  local Xin = {}
  local total = 0
  local total_set_io_t = 0
  local total_test_t = 0
  local iter = 10000
  math.randomseed( os.time() )
  for i = 1, iter do
    for i = 1, npl[1] do
      local num = math.random() + math.random(-4, 4)
      Xin[i] = Scalar.new(num, "F4")
    end
    start_t = qc.RDTSC()
    local out, test_t, set_io_t = x:predict(Xin)
    end_t = qc.RDTSC()
    total_test_t = total_test_t + test_t
    total_set_io_t = total_set_io_t + set_io_t
    total = total + tonumber(end_t - start_t)
  end
  print("Average 'test + set_io' cycles = " .. (total/iter))
  print("Average test cycles = " .. (total_test_t/iter))
  print("Average set_io predict cycles = " .. (total_set_io_t/iter))
  print("time = " .. ((total_set_io_t/iter)/(2.5 * 1000 * 1000)))
  print("Test t2 succeeded")
end

tests.t3 = function()
  local batch_size = 1
  npl = { 10, 4, 2, 1 }
  dpl = { 0, 0, 0, 0 }
  afns = { '', 'relu', 'relu', 'sigmoid' }
  local in_table = {}
  in_table[#in_table+1] = 0.5647786238614011
  in_table[#in_table+1] = 0.9774114965478293
  in_table[#in_table+1] = 1.0
  in_table[#in_table+1] = 0.5832110822814642
  in_table[#in_table+1] = 0.4623549735995053
  in_table[#in_table+1] = 0.13900426916603753
  in_table[#in_table+1] = 0.0
  in_table[#in_table+1] = 0.2742994756532942
  in_table[#in_table+1] = 0.14620294203084275
  in_table[#in_table+1] = 0.5161237751406931

  local exp_out = 0.4968680002374564

  local Xin = {}
  for i = 1, npl[1] do
    Xin[i] = Scalar.new(in_table[i], "F4")
  end

  print("Network structure")
  print("n_layers = " .. #npl)
  local npl_str = ''
  for i, v in pairs(npl) do
    npl_str = npl_str .. "-" .. tostring(v)
  end
  print("structure = " .. npl_str)
  local start_t = qc.RDTSC()
  local x = ldnn.new({ npl = npl, dpl = dpl, activation_functions = afns} )
  local end_t = qc.RDTSC()
  print("dnn_new = " .. tonumber(end_t - start_t))

  --[[
  start_t = qc.RDTSC()
  x:set_io_predict(Xin)
  end_t = qc.RDTSC()
  print("set_io = " .. tostring(end_t - start_t))
  ]]

  start_t = qc.RDTSC()
  x:set_batch_size(batch_size)
  end_t = qc.RDTSC()
  print("set_batch = " .. tonumber(end_t - start_t))

  print("testing started")
  start_t = qc.RDTSC()
  local out, test_t, set_io_t = x:predict(Xin)
  end_t = qc.RDTSC()
  print("out = " .. out:to_num())
  print("Average 'test + set_io' cycles = " .. tonumber(end_t-start_t))
  print("Average test cycles = " .. tonumber(test_t))
  print("Average set_io predict cycles = " .. tonumber(set_io_t))

  print("Test t3 succeeded")
end

return tests

