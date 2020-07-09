
local function nop() end 
print = nop -- Comment this out if you want print statements
local gen_code = require 'Q/UTILS/lua/gen_code'
local plpath = require 'pl.path'
local srcdir = '../gen_src/'
local incdir = '../gen_inc/'
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file))
local operators = assert(dofile(operator_file))
local num_produced = 0
local types = { 'B1' }
for i, operator in ipairs(operators) do
  local sp_fn = assert(require (operator .. '_specialize'))

  for i, in1type in ipairs(types) do 
    for j, in2type in ipairs(types) do 
      local status, subs = pcall(sp_fn, in1type, in2type)
      if ( status ) then 
        assert(type(subs) == "table")
        gen_code.doth(subs, incdir)
        gen_code.dotc(subs, srcdir)
        print("Produced ", subs.fn)
        num_produced = num_produced + 1
      end
    end
  end
end
assert(num_produced > 0)
