local gen_code = require("Q/UTILS/lua/gen_code")
local num_produced = 0
local sp_fn = assert(require("vnot_specialize"))

local function generate_files(in_qtype, args)
  local subs = assert(sp_fn(in_qtype, args))
  assert(type(subs) == "table")
  gen_code.doth(subs, subs.incdir)
  gen_code.dotc(subs, subs.srcdir)
  print("Produced ", subs.fn)
  num_produced = num_produced + 1
  return true
end

for _, in_qtype in ipairs({"B1"}) do
  assert(generate_files(in_qtype))
end
assert(num_produced > 0)
