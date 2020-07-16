local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local Scalar  = require 'libsclr'
local function chk_inputs(f1, sclrs, optargs)
  assert(type(f1) == "lVector")
  assert(not f1:has_nulls())
  if ( optargs ) then 
    assert(type(optargs) == "table")
  end
  if ( sclrs ) then
    if ( type(sclrs) ~= "Scalar" ) then
      assert(type(sclrs) == "table")
      for _, v in pairs(sclrs) do 
        assert(type(v) == "Scalar")
      end
    end
  end
  return true
end
return chk_inputs
