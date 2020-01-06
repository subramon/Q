require 'Q/UTILS/lua/strict'
local gen_code = require 'Q/UTILS/lua/gen_code'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local plpath   = require "pl.path"
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local modes = { "simple", "opt" }
local types = { 'F4', 'F8' }

local num_produced = 0
for i, mode in ipairs(modes) do
  local sp_fn = assert(require('mv_mul_specialize'))
  for i, x_qtype in ipairs(types) do 
    local X = {}
    X[1] = lVector( {qtype = x_qtype, has_nulls = false, gen  = true})
    for j, y_qtype in ipairs(types) do 
      local y = lVector( {qtype = y_qtype, has_nulls = false, gen = true})
      for k, z_qtype in ipairs(types) do 
        local optargs = { z_qtype = z_qtype, mode = mode } 
        local status, subs = pcall(
        sp_fn, X, y, optargs)
        if ( status ) then 
          assert(type(subs) == "table")
          -- for k, v in pairs(subs) do print(k, v) end
          gen_code.doth(subs, incdir)
          gen_code.dotc(subs, srcdir)
          print("Produced ", subs.fn)
          num_produced = num_produced + 1
        else
          print(status)
          print(subs)
        end
      end
    end
  end
end
assert(num_produced > 0)
print("Generated " ..  num_produced .. " files" )
