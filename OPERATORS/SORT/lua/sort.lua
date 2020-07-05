local cutils  = require 'libcutils'
local Q       = require 'Q/q_export'
local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function sort(x, ordr)
  assert(type(x) == "lVector")
  assert(x:is_eov())
  assert(type(ordr) == "string")
  local spfn = require("Q/OPERATORS/SORT/lua/sort_specialize" )
  local status, subs = pcall(spfn, x:fldtype(), ordr)
  assert(status, "error in call to sort_specialize")
  assert(type(subs) == "table", "error in call to sort_specialize")
  local func_name = assert(subs.fn)

  subs.incs = { "OPERATORS/SORT/gen_inc/" }
  qc.q_add(subs)

  -- TODO P3 Check is already sorted correct way and don't repeat
  local x_len, x_chunk, nn_x_chunk = x:start_write()
  assert(x_len > 0, "Cannot sort null vector")
  assert(not nn_x_chunk, "Cannot sort with null values")
  local start_time = cutils.rdtsc()
  assert(qc[func_name], "Unknown function " .. func_name)
  qc[func_name](get_ptr(x_chunk), x_len)
  record_time(start_time, func_name)
  x:end_write()
  x:set_meta("sort_order", ordr)
  return x

end
return require('Q/q_export').export('sort', sort)
