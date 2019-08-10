local gen_code = require("Q/UTILS/lua/gen_code")
local Scalar = require 'libsclr'
local plpath = require "pl.path"
local pltable = require "pl.tablex"
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local operators = { "shift_left", "shift_right" }
local qtypes = { 'I1', 'I2', 'I4', 'I8' }
local num_produced = 0
for _, operator in pairs(operators) do
    local sp_fn = assert(require(operator .. "_specialize"))
    for _, qtype in pairs(qtypes) do
      local s = Scalar.new(1, qtype)
      status, subs = pcall(sp_fn, qtype, s)
      if ( status ) then 
        assert(type(subs) == "table")
        gen_code.doth(subs, incdir)
        gen_code.dotc(subs, srcdir)
        print("Produced ", subs.fn)
        num_produced = num_produced + 1
      else
        print(subs) print(operator) print(fldtype) print(scalar_type)
        assert(nil)
      end
    end
end
assert(num_produced > 0)
