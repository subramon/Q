#!/usr/bin/env lua
local incdir = "../gen_inc/"
local srcdir = "../gen_src/"
local plpath = require 'pl.path'
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local gen_code = require 'Q/UTILS/lua/gen_code'

local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

local num_produced = 0
local spfn = require 'mk_comp_key_val_specialize'
  for k, f in ipairs(qtypes) do 
    local status, subs, tmpl = pcall(spfn, f, o)
    if ( not status ) then print(subs) end
    assert(status)
    assert(type(subs) == "table")
    gen_code.doth(subs, tmpl, incdir)
    gen_code.dotc(subs, tmpl, srcdir)
    print("Produced ", subs.fn)
    num_produced = num_produced + 1
  end
assert(num_produced > 0)
