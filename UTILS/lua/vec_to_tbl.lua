local T = {}
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'

-- Q.vec_to_tbl(x) : gives table of scalars
            -- Return value:
              -- table of scalar values

-- Convention: Q.vec_to_tbl(vector)
-- 1) vector : a vector

local function vec_to_tbl(x)
  assert(x and type(x) == "lVector", "input must be of type lVector")
  -- Check the vector for eval(), if not then call eval()
  if not x:is_eov() then
    x:eval()
  end

  local tbl_of_sclr = {}
  for i = 1, x:num_elements() do
    local value = x:get1(i-1)
    assert(type(value) == "Scalar")
    tbl_of_sclr[i] = value
  end

  return tbl_of_sclr
end

T.vec_to_tbl = vec_to_tbl
require('Q/q_export').export('vec_to_tbl', vec_to_tbl)

return T
