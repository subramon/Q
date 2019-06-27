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
  local get_nDR     = require 'Q/RUNTIME/AGG/lua/get_nDR'
  local mk_template = require 'Q/RUNTIME/AGG/lua/mk_template'

  -- START: Basic checks on input 
  nDR, in_vecs = get_nDR(Tk)
  -- currently only one value can be aggregated
  assert(type(val_vec) == "lVector") 
  local vtype = val_vec:fldtype()
  assert ( ( vtype == "I1" ) or ( vtype == "I2" ) or ( vtype == "I4" ) or 
           ( vtype == "I8" ) or ( vtype == "F4" ) or ( vtype == "F8" ) )
  assert(type(Tk) == "table")
  local tmpl, nR, nD, nC = mk_template(nDR)
  assert(nil)

  -- STOP: Basic checks on input 

  local start_time = qc.RDTSC()
  
  record_time(start_time, func_name)
  return key_vec, val_vec

end
return mdb
