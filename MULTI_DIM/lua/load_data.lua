local Q               = require 'Q'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local function load_data(
  )
  
  --======================
  local T = Q.load_csv("TBD") 
  -- if ( D[k] ) then k needs to be binned using D[k]
  local D = Q.load_csv("TBD") 
  -- Check on D
  for k, v in pairs(D) do 
    assert(T[k])
    assert(type(v) == "lVector")
    assert(v:fldtype() == T[k]:fldtype())
  end
  --======================
  M = Q.load_csv("TBD") -- M[k] are the metrics 
  -- Check on M
  for k, v in pairs(M) do 
    assert(T[k])
    assert(not D[k])
    assert(is_base_qtype(v:fldtype()))
  end
  --======================
  bin_T = {} -- this is a global that we want to persist
  for k, v in pairs(T) do
    if ( D[k] ) then 
      bin_T[k] = Q.bin(V, D[k])
    else
      bin_T[k] = v
    end
  end
  --=======================================
  -- Delete data before pre-processing
  for k, v in pairs(T) do
    v:delete()
  end
  T = bin_T
  return T, M
end
--=======================================
return load_data
  
  
