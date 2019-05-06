local plpath = require 'pl.path'
local lDictionary = require 'Q/RUNTIME/lua/lDictionary'
local qconsts    = require 'Q/UTILS/lua/q_consts'
local qc         = require 'Q/UTILS/lua/q_core'
require 'Q/UTILS/lua/strict'

local tests = {} 
--
tests.t1 = function()
  local fmap = {}
  fmap[1] = "abc"
  fmap[2] = "def"
  fmap[3] = "ghi"
  local D = lDictionary(fmap)
  assert(D:check())
  D:pr("reverse")
  D:pr("forward")
  print("Successfully completed test t1")
end
tests.t2 = function()
  local fmap = {}
  fmap[1] = "abc"
  fmap[2] = "def"
  fmap[3] = "ghi"
  fmap[4] = "ghi"
  local status, msg = pcall(lDictionary, fmap)
  assert(not status)
  print("Successfully completed test t2")
end
tests.t3 = function()
  local fmap = {}
  fmap[1] = "abc"
  fmap[2] = "def"
  fmap[3] = "ghi"
  local D = lDictionary(fmap)
  assert(D:check())
  local str = D:reincarnate()
  --[[ TODO P3 Need to test results better
  str = "lDictionary = require 'Q/RUNTIME/lua/lDictionary'; return " .. str
  print(str)
  local y = loadstring(str)
  print(type(y))
  assert(type(y) == "function")
  local x = y()
  assert(type(x) == "lDictionary")
  --]]

  print("Successfully completed test t3")
end
return tests
