local gen_code = require 'Q/UTILS/lua/gen_code'
local plpath   = require "pl.path"
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local num_produced = 0

local grpby_qtypes = { 'I1', 'I2', 'I4', 'I8' }
local operators = { 'numby' }
local is_safes = { true, false }
for k, operator in pairs(operators) do 
  local sp_fn = assert(require((operator .. "_specialize")))
  for k, is_safe in pairs(is_safes) do 
    for j, grpby_qtype in ipairs(grpby_qtypes) do 
     local status, subs, tmpl = pcall(
       sp_fn, grpby_qtype, is_safe)
      if ( status ) then 
        assert(type(subs) == "table")
        assert(type(tmpl) == "string")
        -- for k, v in pairs(subs) do print(k, v) end
        -- print(tmpl)
        gen_code.doth(subs, tmpl, incdir)
        gen_code.dotc(subs, tmpl, srcdir)
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
