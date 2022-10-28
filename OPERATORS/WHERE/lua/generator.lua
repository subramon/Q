local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local gen_code =  require("Q/UTILS/lua/gen_code")

qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

local sp_fn = require 'Q/OPERATORS/WHERE/lua/where_specialize'
local num_produced = 0

for _, a_qtype in ipairs(qtypes) do
  a = lVector.new({qtype = a_qtype})
  for _, b_qtype in ipairs{ "B1", "BL", } do 
    b = lVector.new({qtype = b_qtype}) 
    local status, subs = pcall(sp_fn, a, b)
    if ( status ) then
      gen_code.doth(subs, subs.incdir)
      gen_code.dotc(subs, subs.srcdir)
      print("Generated ", subs.fn)
      num_produced = num_produced + 1
    else
      print(subs)
    end
  end
end
assert(num_produced > 0)
