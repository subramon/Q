  local plpath = require 'pl.path'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end 
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end 
  local gen_code =  require("Q/UTILS/lua/gen_code")

  local q_qtypes = nil; local bqtypes = nil
  if ( arg[1] ) then 
    a_qtypes = { arg[1] }
  else
    a_qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  end
  if ( arg[2] ) then 
    b_qtypes = { arg[2] }
  else
    b_qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  end

  -- TODO local sort_order = { 'unsorted', 'asc' }
  local sort_order = { 'asc', 'unsorted' }

  local sp_fn = require 'ainb_specialize'
  local num_produced = 0

  for _, b_sort_order  in ipairs(sort_order) do 
    local b_len = 1024
    if ( b_sort_order == "unsorted" ) then b_len = 8 end 
    for _, atype in ipairs(a_qtypes) do 
      for _, btype in ipairs(b_qtypes) do 
        -- print(atype, btype, b_sort_order)
        local status, subs, tmpl = pcall(sp_fn, atype, btype, 
          b_len, b_sort_order)
        if ( status ) then 
          gen_code.doth(subs, tmpl, incdir)
          gen_code.dotc(subs, tmpl, srcdir)
          -- print("Generated ", subs.fn)
          num_produced = num_produced + 1
        else
          print(subs)
        end
      end
    end
  end
  assert(num_produced > 0)
