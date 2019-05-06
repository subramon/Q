local T = {}

-- Q.unpack(x) : gives table of scalars
            -- Return value:
              -- table of scalar values

-- Convention: Q.unpack(vector)
-- 1) vector : a vector

local function unpack(x)
  assert(x and type(x) == "lVector", "input must be of type lVector")
  -- Check the vector for eval(), if not then call eval()
  if not x:is_eov() then
    x:eval()
  end
  
  local tbl_of_sclr = {} 
  for i = 0, x:length()-1 do
    local value = x:get_one(i)
    tbl_of_sclr[#tbl_of_sclr + 1] = value
  end
  
  return tbl_of_sclr
end

T.unpack = unpack
require('Q/q_export').export('unpack', unpack)

return T
