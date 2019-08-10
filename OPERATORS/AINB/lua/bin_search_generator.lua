  local qconsts = require 'Q/UTILS/lua/q_consts'
  local plpath = require 'pl.path'
  local srcdir = "../gen_src/"; 
  local incdir = "../gen_inc/"; 
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
  local gen_code = require("Q/UTILS/lua/gen_code")

  local qtypes 
  if arg[1] then 
    qtypes = { arg[1] }
  else
    qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  end

  local tmpl = "bin_search.tmpl"
  assert(plpath.isfile(tmpl))
  local num_produced = 0
  -- ==================
  for i, qtype in ipairs(qtypes) do 
     local subs = {} 
     subs.fn    = "bin_search_" .. qtype
     subs.ftype = assert(qconsts.qtypes[qtype].ctype)
     gen_code.doth(subs, tmpl, incdir)
     gen_code.dotc(subs, tmpl, srcdir)
     print("Generated ", subs.fn)
     num_produced = num_produced + 1
  end
  assert(num_produced > 0)
