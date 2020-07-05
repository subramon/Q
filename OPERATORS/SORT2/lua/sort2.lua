local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function sort2(x, y, ordr)
  assert(type(x) == "lVector", "error")
  assert(type(y) == "lVector", "error")
  -- Check the vector x for eval(), if not then call eval()
  assert(x:is_eov())
  assert(y:is_eov())
  assert(not x:has_nulls())
  assert(not y:has_nulls())
  x:flush_all() -- TODO P3 Delete later
  y:flush_all() -- TODO P3 Delete later
  -- Flush needed because start_write assumes file exists
  assert(type(ordr) == "string")
  if ( ordr == "ascending" )  then ordr = "asc" end
  if ( ordr == "descending" ) then ordr = "dsc" end
  local spfn = require("Q/OPERATORS/SORT2/lua/sort2_specialize" )
  local status, subs = pcall(spfn, x:fldtype(), y:fldtype(), ordr)
  assert(status, "error in call to sort2_asc_specialize")
  assert(type(subs) == "table", "error in call to sort2_asc_specialize")
  local func_name = assert(subs.fn)

  subs.incs = { "OPERATORS/SORT2/gen_inc/", "UTILS/inc" }
  qc.q_add(subs)

  local x_len, x_chunk = x:start_write()
  local y_len, y_chunk = y:start_write()
  assert(x_len == y_len)
  assert(y_len > 0)
  assert(qc[func_name], "Unknown function " .. func_name)
  local cst_x_chunk = get_ptr(x_chunk, x:qtype())
  local cst_y_chunk = get_ptr(y_chunk, y:qtype())
  qc[func_name](cst_x_chunk,cst_y_chunk, x_len)
  x:end_write()
  y:end_write()
  x:start_write()
  x:end_write()
  -- TODO P2 Set meta data for x, not for y
  return x, y
end
return require('Q/q_export').export('sort2', sort2)
