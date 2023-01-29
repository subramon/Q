local Scalar = require 'libsclr'
local f_to_s = require 'Q/OPERATORS/F_TO_S/lua/f_to_s'

local T = {}
local function fold( fns, vec)
  assert(type(vec) == "lVector")
  -- make sure functions are unique
  local cnt = 0
  for i1, v1 in ipairs(fns) do
    for i2, v2 in ipairs(fns) do
      if ( i1 ~= i2 ) then assert(v1 ~= v2) end 
    end
    cnt = cnt + 1 
  end
  assert(cnt > 0)
  --==================
  local status = true
  local  gens = {}
  for i, v in ipairs(fns) do
    gens[i] = f_to_s[v](vec)
    assert(type(gens[i]) == "Reducer")
  end
  repeat
    for i, v in ipairs(fns) do
      status = gens[i]:next() 
    end
  until not status
  local rvals = {}
  for i, v in ipairs(fns) do
    local key = fns[i]
    -- this is ugly TODO P3 
    local T = {}
    local x, y, z = gens[i]:value() 
    T[1] = x 
    T[2] = y 
    T[3] = z 
    --======================
    rvals[key] = T
  end
  for i, v in ipairs(fns) do
    gens[i]:delete()
  end
  return rvals
  -- return a table of tables
end
T.fold = fold
require('Q/q_export').export('fold', fold)
return T
