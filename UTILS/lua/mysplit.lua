local function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end
return mysplit
--[[
local example = "an;example;string;;"
local t = mysplit(example, ";")
for k, v in pairs(t) do print(k,v ) end 
--]]
