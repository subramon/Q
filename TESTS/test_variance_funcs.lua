-- FUNCTIONAL
local Q = require 'Q'
local Scalar = require 'libsclr'
require 'Q/UTILS/lua/strict'

local c1 = Q.mk_col({-0.494191, -0.472019, 0.730111}, "F8")
local c2 = Q.mk_col({-0.558050, 0.816142, 0.149979}, "F8")
local c3 = Q.mk_col({0.6667, 0.3333, 0.6667}, "F8")

local n = 3
local sn = Scalar.new(n, "F8")
local tests = {}
tests.t1 = function()
  local c1mean = Q.sum(c1):eval() / sn
  assert((c1mean - Scalar.new(-0.0787, "F8")):abs() < Scalar.new(0.01, "F8"))
--[[
  local c2mean = Q.sum(c2):eval() / sn
  local c3mean = Q.sum(c3):eval() / sn
  
  local diff1 = Q.vssub(c1, c1mean)
  local sigma1 = math.sqrt((1 / (n - 1)) * Q.sum_sqr(diff1):eval())
  assert(math.abs(sigma1 - 0.7) < 0.01)
  local stdc1 = Q.vsdiv(diff1, sigma1)
  local stdc1mean = Q.sum(stdc1):eval() / n
  local stddiff1 = Q.vssub(stdc1, stdc1mean)
  local stdsigma1 = math.sqrt((1 / (n - 1)) * Q.sum_sqr(stddiff1):eval())
  assert(math.abs(stdsigma1 - 1) <= 0.0001)
  
  local diff2 = Q.vssub(c2, c2mean)
  local sigma2 = math.sqrt((1 / (n - 1)) * Q.sum_sqr(diff2):eval())
  local stdc2 = Q.vsdiv(diff2, sigma2)
  local stdc2mean = Q.sum(stdc2):eval() / n
  local stddiff2 = Q.vssub(stdc2, stdc2mean)
  local stdsigma2 = math.sqrt((1 / (n - 1)) * Q.sum_sqr(stddiff2):eval())
  assert(math.abs(stdsigma2 - 1) <= 0.0001)
  
  local diff3 = Q.vssub(c3, c3mean)
  local sigma3 = math.sqrt((1 / (n - 1)) * Q.sum_sqr(diff3):eval())
  local stdc3 = Q.vsdiv(diff3, sigma3)
  local stdc3mean = Q.sum(stdc3):eval() / n
  local stddiff3 = Q.vssub(stdc3, stdc3mean)
  local stdsigma3 = math.sqrt((1 / (n - 1)) * Q.sum_sqr(stddiff3):eval())
  assert(math.abs(stdsigma3 - 1) <= 0.0001)
--]]
  
end
--======================================
return tests
