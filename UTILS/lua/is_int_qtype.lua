local int_types = { 
  "BL", "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", 
}
local X = {}
for _, int_type in ipairs(int_types) do
  X[int_type] = true
end
local function is_int_qtype (qtype)
  assert(type(qtype) == "string")
  if X[qtype] then return true else return false end 
end
return is_int_qtype
