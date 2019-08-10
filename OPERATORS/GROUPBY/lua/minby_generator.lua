local gen_code = require 'Q/UTILS/lua/gen_code'
local plpath   = require "pl.path"
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local num_produced = 0

local val_qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8'}
local grpby_qtypes = { 'I1', 'I2', 'I4', 'I8' }
local operators = { 'minby' }
for k, operator in pairs(operators) do 
  local sp_fn = assert(require((operator .. "_specialize")))
  for i, val_qtype in ipairs(val_qtypes) do 
    for j, grpby_qtype in ipairs(grpby_qtypes) do 
     local status, subs = pcall(
       sp_fn, val_qtype, grpby_qtype, optargs)
      if ( status ) then 
        assert(type(subs) == "table")
        -- for k, v in pairs(subs) do print(k, v) end
        gen_code.doth(subs, incdir)
        gen_code.dotc(subs, srcdir)
        print("Produced ", subs.fn)
        num_produced = num_produced + 1
      else
        print(subs)
        break
      end
    end
  end
end
assert(num_produced > 0)
