#!/usr/bin/env lua
local incdir = "../gen_inc/"
local srcdir = "../gen_src/"
local plpath = require 'pl.path'
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local gen_code = require 'Q/UTILS/lua/gen_code'

local order = { 'asc', 'dsc' }
local f1_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
local f2_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

local num_produced = 0
local spfn = require 'sort2_specialize'
for _, o in ipairs(order) do
  for _, f1 in ipairs(f1_qtypes) do
    for _, f2 in ipairs(f2_qtypes) do
      local status, subs = pcall(spfn, f1, f2, o)
      if ( not status ) then print(subs) end
      assert(status)
      assert(type(subs) == "table")
      gen_code.doth(subs, incdir)
      gen_code.dotc(subs, srcdir)
      print("Produced ", subs.fn)
      num_produced = num_produced + 1
    end
  end
end
assert(num_produced > 0)
