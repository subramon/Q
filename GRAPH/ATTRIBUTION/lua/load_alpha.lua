local Q = require 'Q'

local function load_alpha()
  local A = 
  {
    {  1 },
    {  2/3, 1/3 },
    {  4/7, 2/7, 1/7 },
    {  8/15, 4/15, 2/15, 1/15 },
    {  16/31, 8/31, 4/31, 2/31, 1/31 },
    {  32/63, 16/63, 8/63, 4/63, 2/63, 1/63, },
    {  64/127, 32/137, 16/127, 8/127, 4/127, 2/127, 1/127, },
    {  128/255, 64/255, 32/255, 16/255, 8/255, 4/255, 2/255, 1/255, },
  }
  -- create AT which is transpose of A
  local AT = {}
  for i = 1, #A do
    AT[i] = {}
  end
  for i = 1, #A do
    for j = 1, #A - i + 1 do
      if ( not ( A[j+i-1] ) ) then
        assert(nil, "ERROR")
      end
      if ( not ( A[j+i-1][i]) ) then
        assert(nil, "ERROR")
      end
      AT[i][j] = A[j+i-1][i]
    end
  end
  -- convert to table of Vectors
  local alpha = {}
  for i = 1, #A do
    alpha[i] = Q.mk_col(AT[i], "F4")
  end
  --[[
  for i = 1, #A do
    for j = 1, #A do
      if ( beta[i][j] ) then 
        print("i,j, alpha = ", i, j, beta[i][j])
      end
    end
  end
  --]]
  return alpha
end
-- load_alpha()
return load_alpha
