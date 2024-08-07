local gen_code = require("Q/UTILS/lua/gen_code")
local qtypes = { 'B1', 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
local num_produced = 0
local sp_fn = assert(require("convert_specialize"))

local function generate_files(in_qtype, out_qtype, args)
  local status, subs = pcall(sp_fn, in_qtype, out_qtype, args)
  if ( status ) then
    assert(type(subs) == "table")
    gen_code.doth(subs, subs.incdir)
    gen_code.dotc(subs, subs.srcdir)
    print("Produced ", subs.fn)
    num_produced = num_produced + 1
  else
    assert(nil, subs)
  end
  return true
end

for _, in_qtype in ipairs(qtypes) do 
  for _, out_qtype in ipairs(qtypes) do 
    if ( out_qtype ~= in_qtype ) then
      status = pcall(generate_files, in_qtype, out_qtype, { is_safe = true })
      assert(status, 
       "Failed to generate files for safe mode " .. in_qtype .. " to " .. out_qtype)
      status = pcall(generate_files, in_qtype, out_qtype, {is_safe = false})
      assert(status, 
       "Failed to generate files for unsafe mode" .. in_qtype .. out_qtype)
    end
  end
end
assert(num_produced > 0)
