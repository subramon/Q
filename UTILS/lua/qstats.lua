--[[
q_export (export) is used *ONLY* to register stuff 
(can be a utility or operator) with Q.
All the operators register themselves with Q using q_export
]]
local function setDefault (t, d)
  local mt = {__index = function (t, k) print("Not registered", k) return d end}
  setmetatable(t, mt)
end

local qfns = {} -- list of functions registered for Q
qfns[0] = function () return nil end 
setDefault(qfns, qfns[0])

qfns.export = function(fname, fn) 
  -- print("registering function with name ", fname)
  qfns[fname] = fn
  return fn
end
return qfns
