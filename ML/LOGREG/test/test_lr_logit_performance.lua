local Q        = require 'Q'
local Scalar   = require 'libsclr'
local qc      = require 'Q/UTILS/lua/q_core'
local lr_logit = require 'Q/ML/LOGREG/lua/lr_logit'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local conjoin  = require 'Q/RUNTIME/lua/conjoin'


local tests = {}
local len = 100000000

tests.t1 = function()
  local x = Q.rand( { lb = 0.1, ub = 0.9, qtype = "F8", len = len } ):set_name("x")
  x:eval()
  local start_time = qc.RDTSC()
  local l1 = Q.logit(x):set_name("t3_a"):eval()
  local l2 = Q.logit2(x):set_name("t4_a"):eval()
  local stop_time = qc.RDTSC()
  print("logit operator combine timing = ", stop_time-start_time)
  --print(l1:length(), l2:length())
end

tests.t2 = function()
  local x = Q.rand( { lb = 0.1, ub = 0.9, qtype = "F8", len = len } ):set_name("x")
  x:eval()
  local start_time = qc.RDTSC()
  local l1, l2 = lr_logit(x, false)
  local stop_time = qc.RDTSC()
  print("lr_logit lock operation timing = ", stop_time-start_time)
  --print(l1:length(), l2:length())
end

tests.t3 = function()
  local x = Q.rand( { lb = 0.1, ub = 0.9, qtype = "F8", len = len } ):set_name("x")
  x:eval()
  local start_time = qc.RDTSC()
  local l1, l2 = lr_logit(x, true)
  conjoin({l1, l2})
  l1:eval()
  local stop_time = qc.RDTSC()
  print("lr_logit timing = ", stop_time-start_time)
  --print(l1:length(), l2:length())
end

return tests
