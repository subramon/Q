-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}

local lVector = require 'Q/RUNTIME/lua/lVector'
local Vector = require 'libvec' 

tests.t1 = function()
-- Set and get should match
  print("about to create vector")
  local x = Vector.new('I4', qconsts.Q_DATA_DIR)
  print("just created create vector")
  local vname = "abc"
  x:set_name(vname)
  assert(x:get_name() == vname)
  print("Completed test t1")
end
--=========================
tests.t2 = function()
  -- cannot set more than 31 characters in name 
  local x = Vector.new('I4', qconsts.Q_DATA_DIR)
  local vname = "01234567890123456789012345678901"
  local status = pcall(x.set_name, vname)
  assert(not status)
end
--=========================
tests.t3 = function()
  -- cannot have comma in name 
  local x = Vector.new('I4', qconsts.Q_DATA_DIR)
  local vname = "abc,def"
  local status = pcall(x.set_name, vname)
  assert(not status)
end
--=========================
tests.t4 = function()
  -- test at lVector level
  local x = Vector.new('I4', qconsts.Q_DATA_DIR)
  local vname = "def"
  x = lVector( { qtype = "I4", gen = true})
  x:set_name(vname)
  assert(x:get_name() == vname)
end
--=========================
tests.t5 = function()
  -- test at lVector level during initiualization
  local x = Vector.new('I4', qconsts.Q_DATA_DIR)
  local vname = "def"
  x = lVector( { qtype = "I4", gen = true, name = vname} )
  print(x:get_name())
  assert(x:get_name() == vname)
end
--=========================
return tests
