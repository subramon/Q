local Scalar = require 'libsclr'

local T = {}

-- Q.is_sorted(x) : checks the sort order of a given input vector(i.e. x)
            -- Return value:
              -- sort_order: 'asc' or 'desc'
              -- else returns nil (i.e. input vector not sorted)

-- Convention: Q.is_sorted(vector)
-- 1) vector : a vector other than B1 qtype

local function is_sorted(x)
  local Q = require 'Q'
  assert(x and type(x) == "lVector", "input must be of type lVector")
    
  local status = false
  local order = nil
  -- is_next(geq) --> sort order is 'asc'
  -- is_next(leq) --> sort order is 'dsc'
  if ( Q.is_next(x, "geq"):eval() ) == true then
    status = true
    order = "asc"
  elseif ( Q.is_next(x, "leq"):eval() ) == true then
    status = true
    order = "dsc"
  end
  return status, order
end
T.is_sorted = is_sorted
require('Q/q_export').export('is_sorted', is_sorted)

return T
