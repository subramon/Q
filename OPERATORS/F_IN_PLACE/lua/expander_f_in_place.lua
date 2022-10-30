local cutils  = require 'libcutils'
local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local is_in   = require 'Q/UTILS/lua/is_in'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_f_in_place(a, x, y)
  assert(type(a) == "string")
  assert(is_in(a, {"sort", "reverse"}))
  local specializer = "Q/OPERATORS/F_IN_PLACE/lua/" .. a .. "_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(x, y))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  if ( a == "sort" ) then
    -- TODO P3 Check is already sorted correct way and don't repeat
    local sort_order = x:get_meta("sort_order")
  end
  local x_len, x_chunk, _ = x:start_write()
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
