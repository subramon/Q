local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local gen_code = require 'Q/UTILS/lua/gen_code'
local plpath   = require 'pl.path'
local plfile   = require 'pl.file'
local function nop() end 
-- print = nop -- Comment this out if you want print statements
local num_produced = 0
--==================================================
local types = { 'I1', 'I2', 'I4', 'I8',  }
local sp_fn = assert(require 'Q/OPERATORS/F1F2OPF3/lua/concat_specialize')

for i, f1_qtype in ipairs(types) do 
  local f1 = lVector.new({ qtype = f1_qtype})
  for j, f2_qtype in ipairs(types) do 
    local f2 = lVector.new({ qtype = f2_qtype})
    for k, f3_qtype in ipairs({ "I2", "I4", "I8" }) do 
      local optargs = { }
      optargs.shift_by  =  16
      optargs.f3_qtype = f3_qtype
      local status, subs = pcall( sp_fn, f1, f2, optargs)
      if ( status) then
        assert(type(subs) == "table")
        gen_code.doth(subs, subs.incdir)
        gen_code.dotc(subs, subs.srcdir)
        if ( subs.fn_ispc ) then 
          local ispc_file, doth_file = 
            assert(gen_code.ispc(subs, subs.srcdir, subs.incdir))
        end
        num_produced = num_produced + 1
        -- print(subs.fn)
      else
        -- print(subs)
      end
    end
  end
end
assert(num_produced > 0)
print("concat_generator produced # files = ", num_produced)
