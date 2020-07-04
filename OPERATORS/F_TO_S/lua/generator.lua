require 'Q/UTILS/lua/strict'
local ffi        = require 'ffi'
local plpath     = require 'pl.path'
local gen_code   = require "Q/UTILS/lua/gen_code"
local for_cdef   = require "Q/UTILS/lua/for_cdef"
local qconsts    =  require 'Q/UTILS/lua/q_consts'
local get_hdr    = require 'Q/UTILS/lua/get_hdr'
local check_subs = require 'Q/OPERATORS/F_TO_S/lua/check_subs'

local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

--========
local operator_file = assert(arg[1])
local operators 
if plpath.isfile(operator_file) then 
  operators = dofile(operator_file)
else
  operators = { arg[1] }
end
--========
local qtypes_file = assert(arg[2])
local qtypes
if plpath.isfile(qtypes_file) then 
  qtypes = dofile(qtypes_file)
else
  qtypes = { arg[2] }
end
local total_num_produced = 0
for _, operator in ipairs(operators) do
  local sp_fn = assert(require(operator .. "_specialize"))
  local num_produced = 0
  for _, qtype in ipairs(qtypes) do 
    if ( ( qtype == "B1" ) and 
         ( ( operator == "min" ) or ( operator == "max" ) ) ) then
         -- nothing to do 
    else
      local status, subs
      status, subs = pcall(sp_fn, qtype)
      assert(status, subs)
      assert(check_subs(subs))
      if ( not subs.tmpl ) then 
        print("Not generating code for " .. subs.fn)
      else
        assert(type(subs) == "table")
        gen_code.doth(subs, subs.incdir)
        gen_code.dotc(subs, subs.srcdir)
        num_produced = num_produced + 1
      end
    end
  end
  assert(num_produced > 0)
  total_num_produced = num_produced + total_num_produced
end
print("Produced " .. total_num_produced .. " files")
