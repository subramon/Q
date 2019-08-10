#!/usr/bin/env lua
local incdir = "../gen_inc/"
local srcdir = "../gen_src/"
local plpath = require 'pl.path'
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local gen_code = require 'Q/UTILS/lua/gen_code'

local qtypes = require 'qtypes'

local spfn = require 'specializer_approx_frequent'
for _, f in ipairs(qtypes) do
  local status, subs = pcall(spfn, f)
  if ( not status ) then print(subs) end
  assert(status)
  assert(type(subs) == "table")
  gen_code.doth(subs, incdir)
  gen_code.dotc(subs, srcdir)
  print("Produced ", subs.fn)
end
