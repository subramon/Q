local Q = require 'Q'
local Scalar = require 'libsclr'

local function voting_1(
  T_train, -- table of m lVectors of length n_train
  m,
  n_train,
  x, -- table of m Scalars
  chk_params
  )
  if ( chk_params ) then 
    assert(x)
    assert(type(x) == "table")
    assert(#x == m)
    for _, v in ipairs(x) do 
      assert(type(v) == "Scalar")
    end
    assert(T_train)
    assert(type(T_train) == "table")
    assert(#T_train == m)
  end
  --==============================================
  -- TODO P2: Have hard coded exponent below
  local exponent = Scalar.new(8, "F4")
  d = {}
  local i = 1
  for k = 1, m do 
    -- d[k] = Q.sqr(Q.vssub(T_train[k], x[k]))
    d[k] = Q.pow(
             Q.vssub(
               T_train[k], 
               x[k]
             ):memo(false), 
             exponent
           ):memo(false)
  end
  local sum_d = d[1]
  for k = 2, m do 
    sum_d = Q.vvadd(d[k], sum_d):eval()
  end
  return Q.reciprocal(
           Q.vsadd(
             sum_d, 
             Scalar.new(1, "F4")
           ):memo(false)
         ):memo(false)
end
return voting_1
