local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
local F = {}
function F.f1(n)
  local n = n or 3 * qconsts.chunk_size  + 17
  
  local prod = {}
  prod[1] = { category = Q.rand({ lb = 0, ub = 127, qtype = "I1", len = n})}
  prod[2] = { is_fmcg = Q.rand({ lb = 0, ub = 1, qtype = "I1", len = n})}
  
  local geo = {}
  geo[1] = { store = Q.rand({ lb = 0, ub = 127, qtype = "I1", len = n})}
  geo[2] = { district = Q.rand({ lb = 0, ub = 127, qtype = "I1", len = n})}
  geo[3] = { state = Q.rand({ lb = 0, ub = 63, qtype = "I1", len = n})}
  geo[4] = { rdc = Q.rand({ lb = 0, ub = 32, qtype = "I1", len = n})}
  
  local time = {}
  time[1] = { day_of_week = Q.rand({ lb = 1, ub = 7, qtype = "I1", len = n})}
  time[2] = { month = Q.rand({ lb = 1, ub = 12, qtype = "I1", len = n})}
  time[3] = { quarter = Q.rand({ lb = 1, ub = 4, qtype = "I1", len = n})}
  
  -- set memo false
  local Tk = {}
  Tk[1] = time
  Tk[2] = geo
  Tk[3] = prod
  for k0, v0 in pairs(Tk) do 
    for k1, v1 in pairs(v0) do 
      for k2, v2 in pairs(v1) do 
        v2:set_name(k2) 
        v2:memo(false) 
      end
    end
  end
  return Tk, n
end
return F
