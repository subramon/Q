local plpath  = require 'pl.path'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local Scalar  = require 'libsclr'
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end 
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end 
local gen_code =  require("Q/UTILS/lua/gen_code")

local q_qtypes = nil; local bqtypes = nil
if ( arg[1] ) then 
  qtypes = { arg[1] }
else
  qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
end

local num_produced = 0

local x = lVector({qtype = "B1"})
variations = { "vv", "vs", "sv", "ss" }
for _, variation in ipairs(variations) do 
  for _, qtype in ipairs(qtypes) do 
    if ( variation == "vv" ) then 
      local y = lVector({qtype = qtype})
      local z = lVector({qtype = qtype})
    elseif ( variation == "vs" ) then 
      local y = lVector({qtype = qtype})
      local z = Scalar.new({val = 0, qtype = qtype})
    elseif ( variation == "sv" ) then 
      local y = Scalar.new({val = 0, qtype = qtype})
      local z = lVector({qtype = qtype})
    elseif ( variation == "ss" ) then 
      local y = Scalar.new({val = 0, qtype = qtype})
      local z = Scalar.new({val = 0, qtype = qtype})
    else
      error("")
    end
    local sp_fn_name = 'ifxthenyelsez_specialize'
    local sp_fn = require(sp_fn_name)
    local status, subs = pcall(sp_fn, variation, x, y, z)
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
