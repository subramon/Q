local plpath = require 'pl.path'
local operators = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/operators'

local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local gen_code =  require("Q/UTILS/lua/gen_code")

local a_qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
local s_qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

local num_produced = 0

for _, op in ipairs(operators) do
  local sp_fn = assert(require('Q/OPERATORS/F1S1OPF2_VAL/lua/' .. op .. "_specialize"))
  for _, a_qtype in ipairs(a_qtypes) do
    for _, s_qtype in ipairs(s_qtypes) do
      local status, subs = pcall(sp_fn, a_qtype, s_qtype)
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

