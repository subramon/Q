local T = {} 
local function clone(x, optargs)
  local Q   = require 'Q/q_export'
  local qc  = require 'Q/UTILS/lua/q_core'
  local ffi = require 'ffi'
  assert(x)
  assert(type(x) == "lVector")
  error("NEEDS MORE THOUGHT AND TESTING")
  -- We are supporting Q.clone() for non_eov vectors as well. In this case it would be similar like VM cloning
  -- when we perform clone on non_eov vector, it's state is getting cloned 
  -- any changes in source vector after cloning, will not reflect in cloned vector and vice-versa
  -- Now removing below condition
  -- assert(x:is_eov(), "Vector must be materialized before cloning")
  return x:clone(optargs)
  --================================================
end
T.clone = clone
require('Q/q_export').export('clone', clone)
return T
