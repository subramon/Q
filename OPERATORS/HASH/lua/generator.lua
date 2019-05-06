local plpath = require 'pl.path'
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local gen_code =  require("Q/UTILS/lua/gen_code")

local out_qtypes = { 'I1', 'I2', 'I4', 'I8' }

local sp_fn = require 'Q/OPERATORS/HASH/lua/hash_specialize'
local num_produced = 0

for _, qtype in ipairs(out_qtypes) do
  local status, subs, tmpl = pcall(sp_fn, {field_type=qtype}, {out_qtype = qtype})
  if ( status ) then
    gen_code.doth(subs, tmpl, incdir)
    gen_code.dotc(subs, tmpl, srcdir)
    print("Generated ", subs.fn)
    num_produced = num_produced + 1
  else
    print(subs)
  end
end
assert(num_produced > 0)
