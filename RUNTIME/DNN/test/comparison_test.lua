local Q = require 'Q'
local lDNN = require 'Q/RUNTIME/DNN/lua/lDNN'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()

  local Xin  = require '_Xin'
  local Xout = require '_Xout'
  local npl  = require '_npl'
  local dpl  = require '_dpl'
  local afns = require '_afns'
--[[
  local npl = {}
  npl[#npl+1] = 10
  npl[#npl+1] = 4
  npl[#npl+1] = 2
  npl[#npl+1] = 1
  local dpl = {}
  dpl[#dpl+1] = 0
  dpl[#dpl+1] = 0
  dpl[#dpl+1] = 0
  dpl[#dpl+1] = 0
  local afns = {}
  afns[#afns+1] = ""
  afns[#afns+1] = "relu"
  afns[#afns+1] = "relu"
  afns[#afns+1] = "sigmoid"
--]]
  local x = lDNN.new({ npl = npl, dpl = dpl, activation_functions = afns} )
  assert(x:check())
  x:set_io(Xin, Xout)
  x:set_batch_size(Xout[1]:length()) -- TODO UNDO HARD CODE 
  x:fit()
  print("Test t4 succeeded")

end
return tests

