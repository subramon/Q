#!/usr/bin/env lua
local gen_code = require 'Q/UTILS/lua/gen_code'

local tm_flds 
local tm_fld = arg[1]
if ( tm_fld ) then 
  tm_flds = { tm_fld }
else
  tm_flds = { 
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
end
local num_produced = 0
local sp_fn = assert(require("Q/OPERATORS/LOAD_CSV/lua/TM_to_I2_specialize"))
for _, tm_fld in ipairs(tm_flds) do
  local status, subs = pcall(sp_fn, tm_fld)
  assert(status, subs)
  gen_code.doth(subs, subs.incdir)
  gen_code.dotc(subs, subs.srcdir)
  print(tm_fld, subs.fn, subs.tm_fld)
end
assert(num_produced >= 0)
