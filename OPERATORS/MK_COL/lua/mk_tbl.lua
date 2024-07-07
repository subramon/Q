-- This is inverse of mk_col 
local lVector   = require 'Q/RUNTIME/VCTR/lua/lVector'
local rev_lkp   =  require 'Q/UTILS/lua/rev_lkp'

local good_qtypes = rev_lkp({ 
  "I1",  "I2",  "I4", "I8",  "UI1",  "UI2",  "UI4", "UI8",  
  "F4", "F8", "BL", "SC"})

local mk_tbl = function (
  invec
  )
  --== START Checks 
  assert(type(invec) == "lVector")
  assert(not invec:has_nulls()) -- TODO P4 
  assert(invec:is_eov())
  assert(good_qtypes[invec:qtype()])

  local tbl = {}
  for k = 1, invec:num_elements() do 
    tbl[#tbl+1] = invec:get1(k-1)
  end
  return tbl
end
return require('Q/q_export').export('mk_tbl', mk_tbl)
