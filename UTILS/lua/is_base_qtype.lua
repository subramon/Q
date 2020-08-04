return function (qtype)
  local cmp_types = { "I1", "I2", "I4", "I8", "F4", "F8" }
  local found = false
  for _, v in ipairs(cmp_types) do
    if ( v == qtype ) then found = true end
  end
  return found
end
