local basetypes = { "BL", "I1", "I2", "I4", "I8", "F4", "F8" }
local X = {}
for _, basetype in ipairs(basetypes) do
  X[basetype] = true
end
local function is_base_qtype (qtype)
  assert(type(qtype) == "string")
  if X[qtype] then return true else return false end 
end
return is_base_qtype
