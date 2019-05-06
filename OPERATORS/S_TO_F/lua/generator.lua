#!/usr/bin/env lua
local gen_code = require 'Q/UTILS/lua/gen_code'
local plpath = require "pl.path"
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file))
local operators = dofile(operator_file)

qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

local args = {}
args.len = 100
for i, operator in ipairs(operators) do
  local num_produced = 0
  print("working on " .. operator)
  local sp_fn = assert(require(operator .. "_specialize"))
  for i, qtype in ipairs(qtypes) do
    -- args.qtype = qtype
    args.qtype = qtype
    if ( operator == "const" ) then 
      args.val = 1
    elseif ( operator == "rand" ) then 
      args.lb = 10
      args.ub = 20
      args.seed = 30
    elseif (operator == "seq" ) then
      args.start = 1
      args.by = 3
    elseif (operator == "period" ) then
      args.start = 1
      args.by = 3
      args.period = 4
    else
      assert(nil, "Control should not come here")
    end
    local status, subs, tmpl = pcall(sp_fn, args)
    assert(status, subs)
    gen_code.doth(subs, tmpl, incdir)
    gen_code.dotc(subs, tmpl, srcdir)
  end
  assert(num_produced >= 0)
end
