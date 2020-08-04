local Scalar   = require 'libsclr'
local gen_code = require("Q/UTILS/lua/gen_code")
local plpath   = require "pl.path"
local pltable  = require "pl.tablex"

local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file), "File not found " .. operator_file)
local operators = dofile(operator_file)
local qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
local integer_operators = { "vsrem", "vsand", "vsor", "vsxor" }
local num_produced = 0
for i, operator in ipairs(operators) do
  local sp_fn = assert(require(operator .. "_specialize"))
  for i, fldtype in ipairs(qtypes) do
    if ( ( pltable.find(integer_operators, operator) ) and ( fldtype == "F4" or fldtype == "F8" ) ) then
      -- Do Nothing
    else
      for j, scalar_type in ipairs(qtypes) do
        -- NOTE: Provide legit scalar_val for each scalar_type
        -- For 6 basic types, 1 is fine but will need to do better
        -- for B1, SC, ...
        local status, subs
        if ( operator == "cum_cnt" ) then 
          local optargs = {}; optargs.in_nR = 1000000
          subs = sp_fn(fldtype, optargs)
        else 
          local s = Scalar.new(1, scalar_type)
          subs = sp_fn(fldtype, s)
        end
        assert(subs)
        if ( subs ~= "ok" )  then 
          assert(type(subs) == "table")
          gen_code.doth(subs, subs.incdir)
          gen_code.dotc(subs, subs.srcdir)
          num_produced = num_produced + 1
        end
      end
    end
  end
end
assert(num_produced > 0)
print("Number of files produced = ", num_produced)
