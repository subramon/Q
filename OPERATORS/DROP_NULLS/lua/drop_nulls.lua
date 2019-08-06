local T = {} 
local function drop_nulls(x, sval)
  local Q   = require 'Q/q_export'
  local qc  = require 'Q/UTILS/lua/q_core'
 local ffi = require 'ffi' 
  local get_ptr = require 'Q/UTILS/lua/get_ptr'
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local to_scalar = require 'Q/UTILS/lua/to_scalar'

  assert(x)
  assert(type(x) == "lVector")
  if ( not x:has_nulls() ) then 
    return x
  end
  -- Check the vector x for eval(), if not then call eval()
  if not x:is_eov() then
    x:eval()
  end  
  assert(x:is_eov(), "Vector must be materialized before dropping nulls")
  assert(sval)
  -- expecting y of type scalar, if not converting to scalar
  sval = assert(to_scalar(sval, x:fldtype()), "y should be a Scalar or number") 
  assert(x:fldtype() == sval:fldtype())
  --================================================
  local spfn = require("Q/OPERATORS/DROP_NULLS/lua/drop_nulls_specialize" )
  local status, subs, tmpl = pcall(spfn, x:fldtype())
  assert(status, "error in call to drop_nulls_specialize")
  assert(type(subs) == "table", "error in call to drop_nulls_specialize")
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)

  -- early return if no nulls 
  if ( x:has_nulls() == false ) then return x end
    
  local xlen, xptr, nn_xptr = x:start_write(true)
  assert(xlen > 0, "Cannot have null vector")
  assert(xptr)
  assert(nn_xptr, "Must have nulls in order to drop them")
  --xptr    = ffi.cast(subs.ctype .. " *", xptr)
  --nn_xptr = ffi.cast("uint64_t *", nn_xptr)
  assert(qc[func_name], "Unknown function " .. func_name)
  local casted_xptr = ffi.cast(qconsts.qtypes[x:fldtype()].ctype .. "*", get_ptr(xptr))
  local casted_nn_xptr = ffi.cast(qconsts.qtypes['B1'].ctype .. "*", get_ptr(nn_xptr))
  local casted_sval = ffi.cast(qconsts.qtypes[x:fldtype()].ctype .. "*", get_ptr(sval:to_cmem()))
  qc[func_name](casted_xptr, casted_nn_xptr, casted_sval, xlen)
  x:drop_nulls()
  x:end_write()
  return x
  --================================================
end
T.drop_nulls = drop_nulls
require('Q/q_export').export('drop_nulls', drop_nulls)
return T
