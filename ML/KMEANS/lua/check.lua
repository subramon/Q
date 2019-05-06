-- https://en.wikipedia.org/wiki/K-means_clustering
local Q = require 'Q'
local Scalar = require 'libsclr'
-- ===========================================
-- nI = number of instances
-- nJ = number of attributes/features
-- nK = number of classes 

local check = {}
check.means = function (means, nJ, nK)
  assert(nJ)
  assert(type(nJ) == "number")
  assert(nJ > 0)

  assert(nK)
  assert(type(nK) == "number")
  assert(nK > 0)

  assert(means)
  assert(type(means) == "table")

  for k, mu_k in pairs(means) do 
    for j, mu_k_j in pairs(mu_k) do 
      assert(type(mu_k_j) == "number") -- TODO P3 Should be Scalar
    end
  end
  return true
end
--===============================
check.class = function (class, nK, is_rough)
  assert(nK)
  assert(type(nK) == "number")

  assert(class)
  assert(type(class) == "lVector")

  local qtype = class:fldtype()
  assert( ( qtype == "I1" ) or
          ( qtype == "I2" ) or
          ( qtype == "I4" ) or
          ( qtype == "I8" ) )
  local n1
  if ( is_rough ) then 
    -- class should be between 1 and nK
    n1 = Q.sum(Q.vvor(Q.vslt(class, 1), Q.vsgt(class, nK))):eval()
  else
    -- class should be between 0 and nK
    n1 = Q.sum(Q.vvor(Q.vslt(class, 0), Q.vsgt(class, nK))):eval()
  end
  assert(n1:to_num() == 0)
  return true
end
--===============================
check.data = function (D)
  assert(D and (type(D) == "table"))
  local nJ = 0
  local nI
  for j, v in pairs(D) do
    if ( not nI ) then 
      nI = v:length()
    else
      assert( nI == v:length())
    end
    nJ = nJ + 1 
  end
  assert(nI > 0)
  return nI, nJ
end
--================================
return check
