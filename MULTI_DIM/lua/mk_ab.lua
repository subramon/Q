local Q = require 'Q'

local function mk_ab(len, p)
  assert( (type(len) == "number") and ( len > 0 ) )
  assert( (type(p) == "number") and ( p > 0 ) and ( p < 1 ) )
  local a = Q.rand( { probability = p, qtype = "B1", len = len }):eval()
  local b = Q.rand( { probability = p, qtype = "B1", len = len }):eval()
  return a, b
end
-- mk_ab(1048575, 0.5)
return mk_ab
