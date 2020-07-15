#!/usr/bin/env lua
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local function nop() end 
-- print = nop -- Comment this out if you want print statements
local gen_code = require 'Q/UTILS/lua/gen_code'
local plpath = require 'pl.path'
local srcdir = '../gen_src/'
local incdir = '../gen_inc/'

if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local operators = assert(dofile 'cmp_operators.lua')
local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

local num_produced = 0
for _, operator in ipairs(operators) do
  local sp_fn = assert(require (operator .. '_specialize'))

  for _, f1_qtype in ipairs(types) do 
    local f1 = lVector.new({qtype = f1_qtype})
    for _, f2_qtype in ipairs(types) do 
      local f2 = lVector.new({qtype = f2_qtype})
      local status, subs = pcall(sp_fn, f1, f2)
      if ( status ) then 
        gen_code.doth(subs, incdir)
        gen_code.dotc(subs, srcdir)
        -- print("Produced ", subs.fn)
        num_produced = num_produced + 1
      else
        print(subs)
      end
    end
  end
end
assert(num_produced > 0)
print("cmp_generator produced # files = ", num_produced)
