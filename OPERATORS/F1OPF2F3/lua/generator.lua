  local gen_code = require 'Q/UTILS/lua/gen_code'
  local plpath   = require "pl.path"
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

  local operator_file = assert(arg[1], "operator file not provided")
  assert(plpath.isfile(operator_file))
  local operators = dofile(operator_file)
  local in1_qtypes = { 'I1', 'I2', 'I4', 'I8', }

  local num_produced = 0
  for i, operator in ipairs(operators) do
    print("Working on operator " .. operator)
    local sp_fn_name = operator .. "_specialize"
    local sp_fn = assert(require(sp_fn_name),
      "specializer not found " .. sp_fn_name)
    for i, in1_qtype in ipairs(in1_qtypes) do 
      local status, subs, tmpl = pcall(
        sp_fn, in1_qtype, optargs)
      if ( status ) then 
        assert(type(subs) == "table")
        assert(type(tmpl) == "string")
          -- for k, v in pairs(subs) do print(k, v) end
          -- print(tmpl)
        gen_code.doth(subs, tmpl, incdir)
        gen_code.dotc(subs, tmpl, srcdir)
        print("Produced ", subs.fn)
        num_produced = num_produced + 1
      else
        print("error in specializer " .. subs)
      end
    end
  end
  assert(num_produced > 0)
  print("Number of files Produced  = ", num_produced)
