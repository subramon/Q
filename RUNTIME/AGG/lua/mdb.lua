-- Inputs are 
-- (a) a table of keys 
-- (2) val_vec, a vector representing value being aggregated
-- (Note that we currently do NOT support aggregation of multiple values
-- Output is 
-- (1) a Vector representing the composite key
-- (2) a Vector representing the value (obtained from Vin)
local function mdb(Tk, val_vec)
  local Q           = require 'Q/q_export'
  local lVector     = require 'Q/RUNTIME/lua/lVector'
  local qc          = require 'Q/UTILS/lua/q_core'
  local get_ptr     = require 'Q/UTILS/lua/get_ptr'
  local record_time = require 'Q/UTILS/lua/record_time'

  -- START: Basic checks on input 
  assert(type(val_vec) == "lVector")
  local vtype = val_vec:fldtype()
  assert ( ( vtype == "I1" ) or ( vtype == "I2" ) or ( vtype == "I4" ) or 
           ( vtype == "I8" ) or ( vtype == "F4" ) or ( vtype == "F8" ) )
  assert(type(Tk) == "table")
  local num_derived_attributes = #Tk
  local shift_by  -- meaning as follows:
  -- shift_by = n => we can encode ID of derived attribute and its value 
  -- n bits)

  -- STOP: Basic checks on input 

  local spfn = require("Q/OPERATORS/SORT/lua/sort_specialize" )
  local status, subs, tmpl = pcall(spfn, x:fldtype(), ordr)
  assert(status, "error in call to sort_specialize")
  assert(type(subs) == "table", "error in call to sort_specialize")
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Missing symbol " .. func_name)

  -- TODO Check is already sorted correct way and don't repeat
  local x_len, x_chunk, nn_x_chunk = x:start_write()
  assert(x_len > 0, "Cannot sort null vector")
  assert(not nn_x_chunk, "Cannot sort with null values")
  local start_time = qc.RDTSC()
  assert(qc[func_name], "Unknown function " .. func_name)
  qc[func_name](get_ptr(x_chunk), x_len)
  record_time(start_time, func_name)
  x:end_write()
  x:set_meta("sort_order", ordr)
  return comp_key_vec, val_vec

end
return mdb
