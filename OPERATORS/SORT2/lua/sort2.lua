local function sort2(x, y, ordr)
  local Q       = require 'Q/q_export'
  local qc = require 'Q/UTILS/lua/q_core'
  local get_ptr = require 'Q/UTILS/lua/get_ptr'
  local ffi = require 'Q/UTILS/lua/q_ffi'
  local qconsts = require 'Q/UTILS/lua/q_consts'

  assert(type(x) == "lVector", "error")
  assert(type(y) == "lVector", "error")
  -- Check the vector x for eval(), if not then call eval()
  if not x:is_eov() then
    x:eval()
  end
  if not y:is_eov() then
    y:eval()
  end
  assert(type(ordr) == "string")
  if ( ordr == "ascending" ) then ordr = "asc" end 
  if ( ordr == "descending" ) then ordr = "dsc" end
  local spfn = require("Q/OPERATORS/SORT2/lua/sort2_specialize" )
  local status, subs, tmpl = pcall(spfn, x:fldtype(), y:fldtype(), ordr)
  assert(status, "error in call to sort2_asc_specialize")
  assert(type(subs) == "table", "error in call to sort2_asc_specialize")
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation

  -- TODO Check is already sorted correct way and don't repeat
  local x_len, x_chunk, nn_x_chunk = x:start_write()
  local y_len, y_chunk, nn_y_chunk = y:start_write()
  assert(x_len > 0, "Cannot sort null vector")
  assert(y_len > 0, "Cannot sort null vector")
  assert(not nn_x_chunk, "Cannot sort with null values")
  assert(not nn_y_chunk, "Cannot sort with null values")
  assert(qc[func_name], "Unknown function " .. func_name)
  local casted_x_chunk = ffi.cast(qconsts.qtypes[x:qtype()].ctype .. "*", get_ptr(x_chunk))
  local casted_y_chunk = ffi.cast(qconsts.qtypes[y:qtype()].ctype .. "*", get_ptr(y_chunk)) 
  qc[func_name](casted_x_chunk,casted_y_chunk, x_len)
  x:end_write()
  y:end_write()
  x:set_meta("sort_order", ordr)
  --TODO for y sort_order???
  return x, y

end
return require('Q/q_export').export('sort2', sort2)
