local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local gen_code = require 'Q/UTILS/lua/gen_code'
local plpath   = require "pl.path"

local function nop() end 
-- print = nop -- Comment this out if you want print statements
local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file))
local operators = dofile(operator_file)
local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

local num_produced = 0
for _, operator in ipairs(operators) do
  local sp_fn = assert(require((operator .. "_specialize")))
  for _, f1_qtype in ipairs(types) do 
    local f1 = lVector.new({ qtype = f1_qtype})
    for _, f2_qtype in ipairs(types) do 
      local f2 = lVector.new({ qtype = f2_qtype})
        local status, subs = pcall( sp_fn, f1, f2, optargs)
        if ( status ) then 
          assert(type(subs) == "table")
          assert(gen_code.doth(subs, subs.incdir))
          assert(gen_code.dotc(subs, subs.srcdir))
          if ( subs.fn_ispc ) then 
            local ispc_file, doth_file = 
              assert(gen_code.ispc(subs, subs.srcdir, subs.incdir))
          end
          num_produced = num_produced + 1
        else
          print(subs)
        end
      end
  end
end
assert(num_produced > 0)
print("#files produced by Arith generator = ", num_produced)
