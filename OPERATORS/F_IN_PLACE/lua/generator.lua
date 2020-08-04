#!/usr/bin/env lua
local plpath   = require 'pl.path'
local gen_code = require 'Q/UTILS/lua/gen_code'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local mk_col   = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local function nop() end 
print = nop -- Comment this out if you want print statements
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
    local invec = mk_col({1, 2, 3}, qtype)
    local subs = assert(spfn(invec, order))
    assert(type(subs) == "table")
    gen_code.doth(subs, subs.incdir)
    gen_code.dotc(subs, subs.srcdir)
    print("Produced ", subs.fn)
    num_produced = num_produced + 1
  end
end
assert(num_produced > 0)
