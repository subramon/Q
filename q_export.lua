--[[
q_export (export) is used *ONLY* to register stuff 
(can be a utility or operator) with Q.
All the operators register themselves with Q using q_export
]]
local function setDefault (t, d)
  local mt = {__index = function (t, k) print("Not registered", k) return d end}
  setmetatable(t, mt)
end


local res = {}
res[0] = function () return nil end 
setDefault(res, res[0])

res.export = function(s, f) 
  -- print("registering ", s)
  res[s] = f
  return f
end
return res
