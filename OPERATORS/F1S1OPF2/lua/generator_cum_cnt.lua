local gen_code = require("Q/UTILS/lua/gen_code")

local operators = { 'cum_cnt' }
local val_qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
local cnt_qtypes = { 'I1', 'I2', 'I4', 'I8' }
local num_produced = 0
for i, operator in ipairs(operators) do
  local fn_name = operator .. "_specialize"
  local sp_fn = assert(require(fn_name))
  for i, val_qtype in ipairs(val_qtypes) do
    for j, cnt_qtype in ipairs(cnt_qtypes) do
      local optargs = {}; 
      optargs.cnt_qtype = cnt_qtype
      status, subs = pcall(sp_fn, val_qtype, nil, optargs)
      if ( status ) then 
        assert(type(subs) == "table")
        gen_code.doth(subs, subs.incdir)
        gen_code.dotc(subs, subs.srcdir)
        print("Produced ", subs.fn)
        num_produced = num_produced + 1
      else
        print(subs)
        print(operator)
        print(fldtype)
        error("premature") 
      end
    end
  end
end
assert(num_produced > 0)
