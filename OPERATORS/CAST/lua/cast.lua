local T = {} 
local function cast(x, new_qtype)
  local Q   = require 'Q/q_export'
  local qc  = require 'Q/UTILS/lua/q_core'
   local ffi = require 'ffi' 
  assert(x)
  assert(type(x) == "lVector")
  assert(x:is_eov(), "Vector must be materialized before casting")
  assert(new_qtype)
  if ( x:fldtype() == new_qtype ) then return x end
  if ( x:has_nulls() ) then assert(nil, "TO BE IMPLEMENTED") end
  return x:cast(new_qtype)
  --================================================
end
T.cast = cast
require('Q/q_export').export('cast', cast)
return T
