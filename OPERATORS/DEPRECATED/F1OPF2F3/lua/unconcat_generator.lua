  local gen_code = require 'Q/UTILS/lua/gen_code'
  local plpath   = require 'pl.path'
  local plfile   = require 'pl.file'
  local srcdir   = '../gen_src/'
  local incdir   = '../gen_inc/'
  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = assert(dofile(operator_file))
  local num_produced = 0
  --==================================================
  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  for i, operator in ipairs(operators) do
    local sp_fn = assert(require(operator .. "_specialize'"))
    for i, in1_qtype in ipairs(types) do 
      local status, subs, tmpl = pcall(
      sp_fn, out1_qtype, out2_qtype, optargs)
      if ( status) then
        assert(type(subs) == "table")
        assert(type(tmpl) == "string")
        gen_code.doth(subs, tmpl, incdir)
        gen_code.dotc(subs, tmpl, srcdir)
        print("Produced ", subs.fn)
        num_produced = num_produced + 1
      end
    end
  end
  assert(num_produced > 0)
