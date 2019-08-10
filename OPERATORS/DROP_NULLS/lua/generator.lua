  local plpath = require 'pl.path'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end 
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end 
  local gen_code =  require("Q/UTILS/lua/gen_code")

  local q_qtypes = nil; local bqtypes = nil
  if ( arg[1] ) then 
    qtypes = { arg[1] }
  else
    qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  end

  local num_produced = 0

    for _, qtype in ipairs(qtypes) do 
      local sp_fn_name = 'drop_nulls_specialize'
      local sp_fn = require(sp_fn_name)
      local status, subs = pcall(sp_fn, qtype)
      if ( status ) then 
        gen_code.doth(subs, incdir)
        gen_code.dotc(subs, srcdir)
        print("Generated ", subs.fn)
        num_produced = num_produced + 1
      else
        print(subs)
      end
    end
  assert(num_produced > 0)
