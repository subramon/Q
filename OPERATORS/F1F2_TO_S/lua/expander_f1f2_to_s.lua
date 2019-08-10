local qconsts = require 'Q/UTILS/lua/q_consts'
local Reducer = require 'Q/RUNTIME/lua/Reducer'
local ffi = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

return function (a, x, y, optargs )
  local sp_fn_name = "Q/OPERATORS/F1F2_TO_S/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name),
  "Specializer missing " .. sp_fn_name)

  assert(type(x) == "lVector", "1 input should be a lVector")
  assert(x:has_nulls() == false, "Not set up for null values as yet")
  local x_qtype = assert(x:fldtype())

  assert(type(y) == "lVector", "2 input should be a lVector")
  assert(y:has_nulls() == false, "Not set up for null values as yet")
  local y_qtype = assert(y:fldtype())

  local status, subs, tmpl = pcall(spfn, x_qtype, y_qtype, optargs)
  assert(status, "Failure of specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Function does not exist " .. func_name)
  local reduce_struct = assert(subs.c_mem)
  local getter = assert(subs.getter)
  assert(type(getter) == "function")

  local cst_x_as = subs.x_ctype .. " *"
  local cst_y_as = subs.y_ctype .. " *"
  --==================
  local chunk_index = 0
  local lgen = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_index)

    local x_len, x_chunk = x:chunk(chunk_index)
    local y_len, y_chunk = y:chunk(chunk_index)
    assert(y_len == x_len)

    chunk_index = chunk_index + 1
    if x_len and ( x_len > 0 )  then
      local cst_x_chunk = ffi.cast(cst_x_as,  get_ptr(x_chunk))
      local cst_y_chunk = ffi.cast(cst_y_as,  get_ptr(x_chunk))
      local cst_struct  = ffi.cast(subs.c_mem_type, get_ptr(reduce_struct))
      local start_time  = qc.RDTSC()
      qc[func_name](cst_x_chunk, x_len, cst_y_chunk, cst_struct)
      record_time(start_time, func_name)
      return reduce_struct
    end
  end
  local s =  Reducer ( { gen = lgen, func = getter, value = reduce_struct} )
  return s
end
