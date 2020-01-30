require 'Q/UTILS/lua/strict'
local ffi        = require 'ffi'
local plpath     = require 'pl.path'
local gen_code   = require "Q/UTILS/lua/gen_code"
local qconsts    =  require 'Q/UTILS/lua/q_consts'
local get_func_decl  = require 'Q/UTILS/build/get_func_decl'
local get_hdr    = require 'Q/UTILS/lua/get_hdr'
local check_subs = require 'Q/OPERATORS/F_TO_S/lua/check_subs'

local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file))
local operators = dofile(operator_file)
local qtypes = { 'B1', 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

-- START Some cdefs that we could have gotten from q_core
local hfile = qconsts.Q_SRC_ROOT .. "/RUNTIME/SCLR/inc/scalar_struct.h"
assert(plpath.isfile(hfile))
incs = qconsts.Q_SRC_ROOT .. "/UTILS/inc/"
local dcl = get_func_decl(hfile, incs)
ffi.cdef(dcl)
--===============
local hfile = qconsts.Q_SRC_ROOT .. "/RUNTIME/CMEM/inc/cmem_struct.h"
assert(plpath.isfile(hfile))
incs = qconsts.Q_SRC_ROOT .. "/UTILS/inc/"
local dcl = get_func_decl(hfile, incs)
ffi.cdef(dcl)
--===============

local function cdef_structs(operator)
  local hfile
  if ( operator == "min" ) then 
    hfile = "../inc/minmax_struct.h"
  elseif ( operator == "max" ) then 
    hfile = "../inc/minmax_struct.h"
  elseif ( operator == "sum" ) then 
    hfile = "../inc/sum_struct.h"
  else
    error(operator)
  end
  assert(plpath.isfile(hfile))
  local hstr = assert(get_hdr(hfile))
  pcall(ffi.cdef, hstr)
  return true
end

local total_num_produced = 0
for _, operator in ipairs(operators) do
  assert(cdef_structs(operator))
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
        gen_code.doth(subs, incdir)
        gen_code.dotc(subs, srcdir)
        num_produced = num_produced + 1
      end
    end
  end
  assert(num_produced > 0)
  total_num_produced = num_produced + total_num_produced
end
print("Produced " .. total_num_produced .. " files")
