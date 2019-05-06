  local gen_code = require 'Q/UTILS/lua/gen_code'
  local plpath   = require "pl.path"
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  plpath.mkdir(srcdir)
  plpath.mkdir(incdir)

  local types = { 'F4', 'F8' }

  local num_produced = 0
  local sp_fn = assert(require("lr_util_specialize"))
  for i, in1_qtype in ipairs(types) do 
    local status, subs, tmpl = pcall( sp_fn, in1_qtype)
    if ( status ) then 
      assert(type(subs) == "table")
      assert(type(tmpl) == "string")
      gen_code.doth(subs, tmpl, incdir)
      gen_code.dotc(subs, tmpl, srcdir)
      print("Produced ", subs.fn)
      num_produced = num_produced + 1
    else
      print(subs)
    end
  end
  assert(num_produced > 0)
