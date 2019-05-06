
local function check_args(x, y)
  assert(type(x) == "lVector")
  assert(type(y) == "lVector")
  assert(not x:has_nulls())
  assert(not y:has_nulls())
  assert(y:is_eov())
  assert(Q.is_geq(y, "next")) -- monotonically increasing
  assert(x:fldtype() == y:fldtype()) -- assumption for now
  return true
end

local function discretize(x, y)
  -- NOTE: Currently, we always return an I1.
  check_args(x, y)
end

return function discretize
