#!/usr/bin/env lua
local ffi      = require 'ffi'
local qconsts  =  require 'Q/UTILS/lua/q_consts'
local get_func_decl  = require 'Q/UTILS/build/get_func_decl'
local get_hdr  = require 'Q/UTILS/lua/get_hdr'
local gen_code = require 'Q/UTILS/lua/gen_code'
local check_subs = require 'Q/OPERATORS/S_TO_F/lua/check_subs'
local plpath   = require "pl.path"

local srcdir   = "../gen_src/"
local incdir   = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file))
local operators = dofile(operator_file)
qtypes = { "B1", "I1", "I2", "I4", "I8", "F4", "F8" }

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
ffi.cdef([[
  struct drand48_data
  {
    unsigned short int __x[3];	/* Current state.  */
    unsigned short int __old_x[3]; /* Old state.  */
    unsigned short int __c;	/* Additive const. in congruential formula.  */
    unsigned short int __init;	/* Flag for initializing.  */
    __extension__ unsigned long long int __a;	/* Factor in congruential
						   formula.  */
  };
   ]])

-- STOP Some cdefs that we could have gotten from q_core

local args = {}
args.len = 100
for i, operator in ipairs(operators) do
  local hfile = "../inc/" .. operator .. "_struct.h"
  assert(plpath.isfile(hfile))
  local hstr = assert(get_hdr(hfile))
  ffi.cdef(hstr)
  local num_produced = 0
  local sp_fn = assert(require(operator .. "_specialize"))
  for i, qtype in ipairs(qtypes) do
    args.qtype = qtype
    -- we need some sample values because specializer needs to
    -- create data structures with input/output values
    if ( operator == "const" ) then 
      args.val = 1
    elseif ( operator == "rand" ) then 
      args.lb = 10
      args.ub = 20
      args.seed = 30
    elseif (operator == "seq" ) then
      args.start = 1
      args.by = 3
    elseif (operator == "period" ) then
      args.start = 1
      args.by = 3
      args.period = 4
    else
      assert(nil, "Control should not come here")
    end
    if ( ( qtype == "B1" ) and 
         ( ( operator == "seq" ) or ( operator == "period" ) ) ) then
         -- do nothing
    else
      if ( qtype == "B1" ) then
        if ( operator == "const" ) then
          args.val = true
        elseif ( operator == "rand" ) then
          args.probability = 0.5
        else
          error("")
        end
      end
      local status, subs = pcall(sp_fn, args)
      assert(status, subs)
      assert(check_subs(subs))
      if ( not subs.tmpl ) then
        print("Not generating code for " .. subs.fn)
      else
        gen_code.doth(subs, incdir)
        gen_code.dotc(subs, srcdir)
        num_produced = num_produced + 1
      end
    end
  end
  print("finished on " .. operator)
--  assert(num_produced >= 0)
end
