local gen_code = require("Q/UTILS/lua/gen_code")
local plpath   = require 'pl.path'

local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file))
local operators = dofile(operator_file)
local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

local num_produced = 0
for i, operator in ipairs(operators) do
  local sp_fn = assert(require(operator .. "_specialize"))
  for i, fldtype in ipairs(qtypes) do 
    local status, subs= pcall(sp_fn, fldtype)
    if ( status ) then 
      assert(type(subs) == "table")
      gen_code.doth(subs, subs.incdir)
      gen_code.dotc(subs, subs.srcdir)
      print("Produced ", subs.fn)
      num_produced = num_produced + 1
    else
      assert(nil, subs)
    end
  end
end
assert(num_produced > 0)
