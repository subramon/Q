local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function expander_f1f2_in_place(a, f1, f2, optargs)
  local specializer = "Q/OPERATORS/F1F2_IN_PLACE/lua/" .. a .. "_specialize"
  local spfn = require(specializer)
  local subs = assert(spfn(f1, f2, optargs))
  local func_name = assert(subs.fn)

  qc.q_add(subs)

  local f1_len, f1_chunk = f1:start_write()
  local f2_len, f2_chunk = f2:start_write()
  assert(f1_len == f2_len)
  assert(f2_len > 0)
  assert(qc[func_name], "Unknown function " .. func_name)
  local cst_f1_chunk = get_ptr(f1_chunk, f1:qtype())
  local cst_f2_chunk = get_ptr(f2_chunk, f2:qtype())
  qc[func_name](cst_f1_chunk, cst_f2_chunk, f1_len)
  f1:end_write()
  f2:end_write()
  -- TODO P2 Set meta data for f1, not for f2
  return f1, f2
end
return expander_f1f2_in_place
