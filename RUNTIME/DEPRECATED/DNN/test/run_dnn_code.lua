local Q = require 'Q'
local lDNN = require 'Q/RUNTIME/DNN/lua/lDNN'
local qc = require 'Q/UTILS/lua/qcore'
local Scalar = require 'libsclr'


function run_dnn(batch_size)
  local batch_size = batch_size or 4096
  local saved_file_path = "dnn_in.txt"
  local n_samples = 1024 * 1024
  print("batch size = ", batch_size)

  -- For the first time, run the prepare_input.lua file to generate input (one time activity)
  Q.restore(saved_file_path)

  print("Network structure")
  print("n_layers = " .. #npl)
  local npl_str = ''
  for i, v in pairs(npl) do
    npl_str = npl_str .. "-" .. tostring(v)
  end
  print("structure = " .. npl_str)
  local start_t = qc.RDTSC()
  local x = lDNN.new({ npl = npl, dpl = dpl, activation_functions = afns} )
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
  print("Test succeeded")
end

return run_dnn
