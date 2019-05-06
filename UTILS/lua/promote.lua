
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
return function(
  ftype1,
  ftype2
  )
  assert(is_base_qtype(ftype1), "Not a valid fldtype" .. ftype1)
  assert(is_base_qtype(ftype2), "Not a valid fldtype" .. ftype2)

  local p = {}
  p.I1 = { I1 = "I1", I2 = "I2", I4 = "I4", I8 = "I8", F4 = "F4", F8 = "F8"}
  p.I2 = { I1 = "I2", I2 = "I2", I4 = "I4", I8 = "I8", F4 = "F4", F8 = "F8"}
  p.I4 = { I1 = "I4", I2 = "I4", I4 = "I4", I8 = "I8", F4 = "F4", F8 = "F8"}
  p.I8 = { I1 = "I8", I2 = "I8", I4 = "I8", I8 = "I8", F4 = "F4", F8 = "F8"}
  p.F4 = { I1 = "F4", I2 = "F4", I4 = "F4", I8 = "F4", F4 = "F4", F8 = "F8"}
  p.F8 = { I1 = "F8", I2 = "F8", I4 = "F8", I8 = "F8", F4 = "F8", F8 = "F8"}

  return (p[ftype1])[ftype2]
end
