local plpath = require 'pl.path'
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local gen_code = require("Q/UTILS/lua/gen_code")

local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file))
local operators = dofile(operator_file)

local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

for i, operator in ipairs(operators) do
  local num_produced = 0
  local sp_fn = assert(require(operator .. "_specialize"))
  for _, xtype in ipairs(types) do 
    for _, ytype in ipairs(types) do 
      local status, subs, tmpl
      status, subs, tmpl = pcall(sp_fn, xtype, ytype)
      if ( status ) then 
        if ( subs ~= "ok_to_fail" ) then 
          assert(type(subs) == "table")
          assert(type(tmpl) == "string")
          gen_code.doth(subs, tmpl, incdir)
          gen_code.dotc(subs, tmpl, srcdir)
          print("Generated ", subs.fn)
          num_produced = num_produced + 1
        end
      else
        print("Failed ", xtype, ytype, status, subs)
      end
    end
  end
  assert(num_produced > 0)
end
