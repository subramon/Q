local qconsts = require 'Q/UTILS/lua/q_consts'
local Reducer = require 'Q/RUNTIME/lua/Reducer'
local ffi = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local to_scalar   = require 'Q/UTILS/lua/to_scalar'

return function (a, x, y, optargs )
  local sp_fn_name = "Q/OPERATORS/COUNT/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name),
  "Specializer missing " .. sp_fn_name)
  assert(type(x) == "lVector", "input x should be a lVector")
  assert(y, "input y should be a scalar or a number")
  -- expecting y of type scalar, if not convert to scalar
  y = assert(to_scalar(y, x:fldtype()), "y should be a Scalar or number")
  assert(x:has_nulls() == false, "Not set up for null values as yet")
  local x_qtype = assert(x:fldtype())
  local status, subs = pcall(spfn, x_qtype, optargs)
  assert(status, "Failure of specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  --STOP: Dynamic compilation

  assert(qc[func_name], "Function does not exist " .. func_name)
  local count = assert(subs.count)
  local getter = assert(subs.getter)
  assert(type(getter) == "function")
  --==================
  local chunk_index = 0
  local bval = y:to_num()
  
  local lgen = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_index)
    local x_len, x_chunk, nn_x_chunk = x:chunk(chunk_index)
    chunk_index = chunk_index + 1
    if x_len and ( x_len > 0 ) then
      local casted_x_chunk = ffi.cast( subs.ctype .. "*",  get_ptr(x_chunk))
      local start_time = qc.RDTSC()
      qc[func_name](casted_x_chunk, x_len, bval, count)
      record_time(start_time, func_name)

      return count[0]
    end
  end
  local s =  Reducer ( { gen = lgen, func = getter, value = count[0]} )
  return s
end
