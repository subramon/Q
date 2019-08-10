  local gen_code = require("Q/UTILS/lua/gen_code")
  local plpath = require "pl.path"
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

  local qtypes = { 'B1' }

  local num_produced = 0
  local sp_fn = assert(require("vnot_specialize"))

  local function generate_files(in_qtype, args)
    local status, subs = pcall(sp_fn, in_qtype, args)
    if ( status ) then
      assert(type(subs) == "table")
      gen_code.doth(subs, incdir)
      gen_code.dotc(subs, srcdir)
      print("Produced ", subs.fn)
      num_produced = num_produced + 1
    else
      assert(nil, subs)
    end
    return true
  end

  for _, in_qtype in ipairs(qtypes) do 
    status = pcall(generate_files, in_qtype)
    assert(status, 
     "Failed to generate files for vnot")
  end
  assert(num_produced > 0)
