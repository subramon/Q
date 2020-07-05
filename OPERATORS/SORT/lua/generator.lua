#!/usr/bin/env lua
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
local qtypes_file = assert(arg[2])
local qtypes
if plpath.isfile(qtypes_file) then 
  qtypes = dofile(qtypes_file)
else
  qtypes = { arg[2] }
end
--========
local num_produced = 0
local spfn = require 'sort_specialize'
for _, order in ipairs(orders) do 
  for _, qtype in ipairs(qtypes) do 
    local status, subs = pcall(spfn, qtype, order)
    if ( not status ) then print(subs) end
    assert(status)
    assert(type(subs) == "table")
    gen_code.doth(subs, subs.incdir)
    gen_code.dotc(subs, subs.srcdir)
    print("Produced ", subs.fn)
    num_produced = num_produced + 1
  end
end
assert(num_produced > 0)
