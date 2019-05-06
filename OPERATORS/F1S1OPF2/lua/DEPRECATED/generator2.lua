  local gen_code = require("Q/UTILS/lua/gen_code")
  local plpath = require "pl.path"
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"

  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = dofile(operator_file)
  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  local num_produced = 0
  for i, operator in ipairs(operators) do
    local sp_fn = assert(require(operator .. "_specialize"))
    for i, fldtype in ipairs(qtypes) do 
      for j, scalar_type in ipairs(qtypes) do 
        -- NOTE: Provide legit scalar_val for each scalar_type
        -- For 6 basic types, 1 is fine but will need to do better
        -- for B1, SC, ...
        local status, subs, tmpl = pcall(sp_fn, fldtype, {lb=1, ub=2}, scalar_type)
        if ( status ) then 
          assert(type(subs) == "table")
          assert(type(tmpl) == "string")
          gen_code.doth(subs,tmpl, incdir)
          gen_code.dotc(subs, tmpl, srcdir)
          print("Produced ", subs.fn)
          num_produced = num_produced + 1
        else
          print(subs)
        end
      end
    end
  end
  assert(num_produced > 0)
