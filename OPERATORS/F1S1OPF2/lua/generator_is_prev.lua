  local gen_code = require("Q/UTILS/lua/gen_code")
  local plpath = require "pl.path"
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  local comparisons = { 'lt', 'gt', 'leq', 'geq', 'eq', 'neq' }

  local optargs = { default = 1 }
  local num_produced = 0
  local sp_fn = assert(require("is_prev_specialize"))
  for i, qtype in ipairs(qtypes) do 
    for j, comparison in ipairs(comparisons) do 
    local status, subs, tmpl = pcall(sp_fn, qtype, comparison, optargs)
      if ( status ) then 
        assert(type(subs) == "table")
        gen_code.doth(subs, tmpl, incdir)
        gen_code.dotc(subs, tmpl, srcdir)
        print("Produced ", subs.fn)
        num_produced = num_produced + 1
      else
        assert(nil, subs)
      end
    end
  end
  assert(num_produced > 0)
