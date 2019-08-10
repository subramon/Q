  local gen_code = require 'Q/UTILS/lua/gen_code'
  local plpath = require 'pl.path'
  local plfile = require 'pl.file'
  local srcdir = '../gen_src/'
  local incdir = '../gen_inc/'
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = assert(dofile(operator_file))
  local num_produced = 0
  --==================================================
  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  for i, operator in ipairs(operators) do
    local sp_fn = require 'concat_specialize'

    for i, in1type in ipairs(types) do 
      for j, in2type in ipairs(types) do 
        for k, out_qtype in ipairs(types) do 
          local optargs = {}
          optargs.out_qtype = out_qtype
          local status, subs = pcall( sp_fn, in1type, in2type, optargs)
          if ( status) then
            assert(type(subs) == "table")
            gen_code.doth(subs, incdir)
            gen_code.dotc(subs, srcdir)
            print("Produced ", subs.fn)
            num_produced = num_produced + 1
          end
        end
      end
    end
  end
  assert(num_produced > 0)
