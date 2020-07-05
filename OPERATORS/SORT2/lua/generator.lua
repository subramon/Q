#!/usr/bin/env lua
-- luajit generator.lua orders.lua  qtypes.lua  qtypes.lua
require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local gen_code = require 'Q/UTILS/lua/gen_code'
--========
local order_file = assert(arg[1])
local orders
if plpath.isfile(order_file) then
  orders = dofile(order_file)
else
  orders = { arg[1] }
end
--========
local qtypes1_file = assert(arg[2])
local qtypes1
if plpath.isfile(qtypes1_file) then
  qtypes1 = dofile(qtypes1_file)
else
  qtypes1 = { arg[2] }
end
--========
local qtypes2_file = assert(arg[3])
local qtypes2
if plpath.isfile(qtypes2_file) then
  qtypes2 = dofile(qtypes2_file)
else
  qtypes2 = { arg[3] }
end
--========
local num_produced = 0
local spfn = require 'sort2_specialize'
for _, order in ipairs(orders) do
  for _, qtype1 in ipairs(qtypes1) do
    for _, qtype2 in ipairs(qtypes2) do
      local status, subs = pcall(spfn, qtype1, qtype2, order)
      if ( not status ) then print(subs) end
      assert(status)
      assert(type(subs) == "table")
      gen_code.doth(subs, subs.incdir)
      gen_code.dotc(subs, subs.srcdir)
      print("Produced ", subs.fn)
      num_produced = num_produced + 1
    end
  end
end
assert(num_produced > 0)
