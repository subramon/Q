local Q = require 'Q'
local Scalar = require 'libsclr'
local chk_params = require 'Q/ML/KNN/lua/chk_params'
local lVector = require 'Q/RUNTIME/lua/lVector'

local function get_k_goals(distance, k_distance, g)
  local val, index
  local k_g = lVector( { qtype = g:qtype(), gen = true, has_nulls = false } )
  for i = 0, k_distance:length()-1 do
    val, _ = k_distance:get_one(i)
    index = Q.index(distance, val)
    val, _ = g:get_one(index)
    k_g:put1(val, nil)
  end
  k_g:eov()
  return k_g
end

local function classify(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  x, -- table of m Scalars
  args
  )

  -- It is a Scalar
  local exponent = Scalar.new(2, "F4")
  if args.exponent then
    exponent = args.exponent
  end

  -- table of m Scalars (scale for different attributes)
  local alpha = args.alpha

  -- number indicating how much neighbours to use
  local k = 5
  if args.k then
    assert(type(args.k) == "number")
    k = args.k
  end

  -- lVector of length m (optional)
  local cnts = args.cnts

  local sone = Scalar.new(1, "F4")
  local szero = Scalar.new(0, "F4")
  --==============================================
  local nT, n, ng = chk_params(T, g, x, exponent, alpha)
  local distance = Q.const({val = szero, qtype = "F4", len = n})
  dk = {}
  local i = 1

  for key, val in pairs(T) do
    dk[i] = Q.vsmul(Q.pow(Q.vssub(val, x[i]), exponent), alpha[i])
    i = i + 1
  end

  for i = 1, nT do
    distance = Q.vvadd(dk[i], distance)
  end

  -- commenting the sqrt operation as it is not required
  --distance = Q.sqrt(distance)
  local k_distance = Q.mink(distance, k):eval()
  local k_g = get_k_goals(distance, k_distance, g)

  -- Now, we need to sum d grouped by value of goal attribute
  local rslt = Q.numby(k_g, ng)
  --[[
  -- Scale by original population, calculate cnts if not given
  local l_cnts
  if ( not cnts ) then 
    local vone = Q.const({ val = sone, qtype = "F4", len = k})
    l_cnts = Q.sumby(vone, k_g, ng)
  else
    l_cnts = cnts
  end
  rslt = Q.vvdiv(rslt, l_cnts)
  ]]
  --=============================
  return rslt 
end

return classify
