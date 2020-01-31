local gen_code = require "Q/UTILS/lua/gen_code"
local plpath   = require 'pl.path'

local srcdir   = "../gen_src/"
local incdir   = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file))
local operators = dofile(operator_file)

local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

for i, operator in ipairs(operators) do
  local num_produced = 0
  local sp_fn = assert(require(operator .. "_specialize"))
  for _, xtype in ipairs(qtypes) do 
    for _, ytype in ipairs(qtypes) do 
      local status, subs, tmpl
      status, subs = pcall(sp_fn, xtype, ytype)
      assert(status, subs)
      assert(type(subs) == "table")
      if ( subs.useful ) then 
        gen_code.doth(subs, tmpl, incdir)
        gen_code.dotc(subs, tmpl, srcdir)
        print("Generated ", subs.fn)
        num_produced = num_produced + 1
      end
    end
  end
  assert(num_produced > 0)
end
