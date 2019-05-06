local gen_code = require("Q/UTILS/lua/gen_code")
local Scalar = require 'libsclr'
local plpath = require "pl.path"
local pltable = require "pl.tablex"
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local operators = { 'cum_cnt' }
local val_qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
local cnt_qtypes = { 'I1', 'I2', 'I4', 'I8' }
local num_produced = 0
for i, operator in ipairs(operators) do
  local sp_fn = assert(require(operator .. "_specialize"))
  for i, val_qtype in ipairs(val_qtypes) do
    for j, cnt_qtype in ipairs(cnt_qtypes) do
      local optargs = {}; 
      optargs.cnt_qtype = cnt_qtype
      status, subs, tmpl = pcall(sp_fn, val_qtype, nil, optargs)
      if ( status ) then 
        assert(type(subs) == "table")
        assert(type(tmpl) == "string")
        gen_code.doth(subs,tmpl, incdir)
        gen_code.dotc(subs, tmpl, srcdir)
        print("Produced ", subs.fn)
        num_produced = num_produced + 1
      else
        print(subs)
        print(operator)
        print(fldtype)
      end
    end
  end
end
assert(num_produced > 0)
