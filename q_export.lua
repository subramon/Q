--[[
q_export (export) is used only to register a stuff (can be a utility or operator) with Q
All the operators register themselves with Q using q_export
]]
local res = {}
res.export = function(s, f) 
    res[s] = f
    return f
end

return res
