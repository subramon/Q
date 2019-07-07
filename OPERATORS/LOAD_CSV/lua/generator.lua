#!/usr/bin/env lua
local gen_code = require 'Q/UTILS/lua/gen_code'
local plpath = require "pl.path"
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

local tm_flds = { 
  "tm_sec",
  "tm_min",
  "tm_hour",
  "tm_mday",
  "tm_mon",
  "tm_year",
  "tm_wday",
  "tm_yday",
  "tm_isdst",
}
local num_produced = 0
local sp_fn = assert(require("Q/OPERATORS/LOAD_CSV/lua/TM_to_I2_specialize"))
for _, tm_fld in ipairs(tm_flds) do
  local status, subs, tmpl = pcall(sp_fn, tm_fld)
  assert(status, subs)
  gen_code.doth(subs, tmpl, incdir)
  gen_code.dotc(subs, tmpl, srcdir)
  print(tm_fld, subs.fn, subs.tm_fld)
end
assert(num_produced >= 0)
