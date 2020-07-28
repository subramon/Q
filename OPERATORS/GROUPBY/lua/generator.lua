local gen_code = require 'Q/UTILS/lua/gen_code'

local num_produced = 0

local val_qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
local grpby_qtypes = { 'I1', 'I2', 'I4', 'I8' }
local operators = { 'sumby' }
local cflds = { true, false }
for k, operator in pairs(operators) do 
  for l, cfld in pairs(cflds) do 
    local sp_fn = assert(require((operator .. "_specialize")))
    for i, val_qtype in ipairs(val_qtypes) do 
      for j, grpby_qtype in ipairs(grpby_qtypes) do 
        local subs = assert(sp_fn(val_qtype, grpby_qtype, cfld))
        assert(type(subs) == "table")
        -- for k, v in pairs(subs) do print(k, v) end
        gen_code.doth(subs, subs.incdir)
        gen_code.dotc(subs, subs.srcdir)
        -- print("Produced ", subs.fn)
        num_produced = num_produced + 1
      end
    end
  end
end
assert(num_produced > 0)
