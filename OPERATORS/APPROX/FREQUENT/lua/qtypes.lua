local types = { "I1", "I2", "I4", "I8", "F4", "F8" }
for _, v in ipairs(types) do
  types[v] = v
end
return types
