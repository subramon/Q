#!/usr/bin/env lua
local ffi      = require 'ffi'
local qconsts  =  require 'Q/UTILS/lua/q_consts'
local for_cdef = require 'Q/UTILS/build/for_cdef'
local get_hdr  = require 'Q/UTILS/lua/get_hdr'
local gen_code = require 'Q/UTILS/lua/gen_code'
local check_subs = require 'Q/OPERATORS/S_TO_F/lua/check_subs'
local plpath   = require "pl.path"

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
--========
-- START Some cdefs needed later 
local incs = { "RUNTIME/SCLR/inc/", "RUNTIME/CMEM/inc/", "UTILS/inc/" }
local x = assert(for_cdef("RUNTIME/SCLR/inc/scalar_struct.h", incs))
ffi.cdef(x)
local x = assert(for_cdef("RUNTIME/CMEM/inc/cmem_struct.h", incs))
ffi.cdef(x)
local x = assert(for_cdef("UTILS/inc/drand_struct.h", incs))
ffi.cdef(x)
-- STOP Some cdefs needed later 

local args = {}
args.len = 100
for i, operator in ipairs(operators) do
  -- cdef the struct file for each operator 
  local hfile = "OPERATORS/S_TO_F/inc/" .. operator .. "_struct.h"
  local hstr = assert(for_cdef(hfile))
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
        gen_code.doth(subs, subs.incdir)
        gen_code.dotc(subs, subs.srcdir)
        num_produced = num_produced + 1
      end
    end
  end
  print("finished on " .. operator)
--  assert(num_produced >= 0)
end
