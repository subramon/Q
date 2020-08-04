local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local gen_code = require 'Q/UTILS/lua/gen_code'

local function nop() end 
print = nop -- Comment this out if you want print statements
local plpath = require 'pl.path'
local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file))
local operators = assert(dofile(operator_file))
local num_produced = 0
local types = { 'B1' }
for _, operator in ipairs(operators) do
  local sp_fn = assert(require (operator .. '_specialize'))

  for _, f1_qtype in ipairs(types) do 
    local f1 = lVector.new({ qtype = f1_qtype})
    for _, f2_qtype in ipairs(types) do 
      local f2 = lVector.new({ qtype = f2_qtype})
      local status, subs = pcall(sp_fn, f1, f2)
      if ( status ) then 
        assert(type(subs) == "table")
        gen_code.doth(subs, subs.incdir)
        gen_code.dotc(subs, subs.srcdir)
        print("Produced ", subs.fn)
        num_produced = num_produced + 1
      end
    end
  end
end
assert(num_produced > 0)
