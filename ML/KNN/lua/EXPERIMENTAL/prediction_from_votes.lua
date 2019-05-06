local Q      = require 'Q'
local Scalar = require 'libsclr'

local function prediction_from_votes(
  V
  )
  assert(type(V) == "table")
  local ng = 0
  local n 
  local lV = {}
  for k, v in pairs(V) do 
    assert(type(v) == "lVector")
    lV[ng] = v
    ng = ng + 1
    if ( not n ) then 
      n = v:length()
    else
      assert(n == v:length())
    end
  end
  assert(ng == 2) -- TODO Not ready for others
  x = Q.vvgeq(lV[0], lV[1])
  -- Note the assumption below that the class labels are 0 and 1
  w = Q.ifxthenyelsez(x, Scalar.new(0, "I4"), Scalar.new(1, "I4"))
  return w
end
return prediction_from_votes
