local function idx_sort(idx, val, ordr)
  local Q       = require 'Q/q_export'
  local qc = require 'Q/UTILS/lua/q_core'
  local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
  local get_ptr = require 'Q/UTILS/lua/get_ptr'
  local ffi     = require 'Q/UTILS/lua/q_ffi'
  local qconsts = require 'Q/UTILS/lua/q_consts'

  assert(type(idx) == "lVector", "error")
  -- Check the vector idx for eval(), if not then call eval()
  if not idx:is_eov() then
    idx:eval()
  end  
  local idx_qtype = idx:fldtype()
  assert( ( (idx_qtype == "I1" ) or (idx_qtype == "I2" ) or 
  (idx_qtype == "I4" ) or (idx_qtype == "I8" ) ), "bad index qtype")

  assert(type(val) == "lVector", "error")
  -- Check the vector val for eval(), if not then call eval()
  if not val:is_eov() then
    val:eval()
  end    
  local val_qtype = val:fldtype()
  assert(is_base_qtype(val_qtype))

  assert(type(ordr) == "string")
  if ( ordr == "ascending"  ) then ordr = "asc" end 
  if ( ordr == "descending" ) then ordr = "dsc" end 
  local spfn = require("Q/OPERATORS/IDX_SORT/lua/idx_sort_specialize" )
  local status, subs, tmpl = pcall(spfn, idx_qtype, val_qtype, ordr)
  assert(status, "error in call to idx_sort_specialize")
  assert(type(subs) == "table", "error in call to idx_sort_specialize")
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)

  local xlen, xptr, nn_xptr = val:start_write()
  assert(xlen > 0, "Cannot sort null vector")
  assert(not nn_xptr, "Cannot sort with null values")

  local ylen, yptr, nn_yptr = idx:start_write()
  assert(xlen == ylen, "val and idx must have same number of elements")
  assert(not nn_yptr, "Cannot sort with null values")

  assert(qc[func_name], "Unknown function " .. func_name)
  local casted_yptr = ffi.cast( qconsts.qtypes[val:fldtype()].ctype .. "*", get_ptr(yptr))
  local casted_xptr =  get_ptr(xptr)
  qc[func_name](casted_yptr, casted_xptr, xlen)
  val:end_write()
  idx:end_write()
  val:set_meta("sort_order", ordr)

end
return require('Q/q_export').export('idx_sort', idx_sort)
