local plpath = require 'pl.path'
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local gen_code =  require("Q/UTILS/lua/gen_code")

ftypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
gtypes = { 'I1', 'I2', 'I4', 'I8' }

local sp_fn = require 'Q/ML/DT/lua/cum_for_dt_specialize'
local num_produced = 0

for _, ftype in ipairs(ftypes) do
  for _, gtype in ipairs(gtypes) do
    local status, subs = pcall(sp_fn, ftype, gtype)
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

assert(num_produced > 0)
