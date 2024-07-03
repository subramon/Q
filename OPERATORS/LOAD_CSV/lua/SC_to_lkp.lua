-- Provides a slow but easy way to convert a string into a number
local SC_to_lkp_L = require 'Q/OPERATORS/LOAD_CSV/lua/SC_to_lkp_L'
local SC_to_lkp_C = require 'Q/OPERATORS/LOAD_CSV/lua/SC_to_lkp_C'
local SC_to_lkp_specialize = 
  require 'Q/OPERATORS/LOAD_CSV/lua/SC_to_lkp_specialize'

local function SC_to_lkp(
  invec, 
  lkp_tbl,
  optargs 
  )
  
  local subs = assert(SC_to_lkp_specialize(invec, lkp_tbl, optargs))
  if ( subs.impl == "Lua" ) then 
    return SC_to_lkp_L(invec, lkp_tbl, subs)
  else -- default implementation 
    return SC_to_lkp_C(invec, lkp_tbl, subs)
  end
end
return require('Q/q_export').export('SC_to_lkp', SC_to_lkp)
