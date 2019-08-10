  local plpath = require 'pl.path'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
  local gen_code =  require("Q/UTILS/lua/gen_code")

  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  local operations = { 'mink', 'maxk' }

  local sp_fn
  local num_produced = 0
  
  for _, op in ipairs(operations) do
    local sp_fn_name = 'Q/OPERATORS/GETK/lua/' .. op .. '_specialize'
    sp_fn = assert(require(sp_fn_name))
    for _, qtype in ipairs(qtypes) do
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
  end

  for _, op in ipairs(operations) do
    local sp_fn_name = 'Q/OPERATORS/GETK/lua/' .. op .. '_specialize_reducer'
    sp_fn = assert(require(sp_fn_name))
    for _, v_qtype in ipairs(qtypes) do
      for _, d_qtype in ipairs(qtypes) do
        local status, subs = pcall(sp_fn, v_qtype, d_qtype)
        if ( status ) then
          gen_code.doth(subs, incdir)
          gen_code.dotc(subs, srcdir)
          print("Generated ", subs.fn)
          num_produced = num_produced + 1
        else
          print(subs)
        end
      end
    end
  end


  assert(num_produced > 0)
