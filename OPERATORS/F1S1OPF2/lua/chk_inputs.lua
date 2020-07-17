local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local Scalar  = require 'libsclr'
local function chk_inputs(f1, sclrs, optargs)
  assert(type(f1) == "lVector")
  assert(not f1:has_nulls())
  if ( optargs ) then 
    assert(type(optargs) == "table")
  end
  -- TODO P3 any checks on Scalars worth doing here?
  return true
end
return chk_inputs
