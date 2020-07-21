local cutils  = require 'libcutils'
local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_f_in_place(a, x, y)
  local specializer = "Q/OPERATORS/F_IN_PLACE/lua/" .. a .. "_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(x, y))
  assert(type(subs) == "table")
  -- subs should contain (1) ordr (if a == "sort") 
  local func_name = assert(subs.fn)

  qc.q_add(subs)

  if ( a == "sort" ) then
    -- TODO P3 Check is already sorted correct way and don't repeat
  end
  local x_len, x_chunk, nn_x_chunk = x:start_write()
  local start_time = cutils.rdtsc()
  local xptr = assert(get_ptr(x_chunk, subs.cst_x_as))
  qc[func_name](xptr, x_len)
  record_time(start_time, func_name)
  x:end_write()
  if ( a == "sort" ) then 
    x:set_meta("sort_order", subs.ordr)
  end
  return x
end
return expander_f_in_place
