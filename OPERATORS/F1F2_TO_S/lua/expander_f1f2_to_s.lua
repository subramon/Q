local qconsts = require 'Q/UTILS/lua/q_consts'
local Reducer = require 'Q/RUNTIME/lua/Reducer'
local ffi = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

return function (a, x, y, optargs )
  local sp_fn_name = "Q/OPERATORS/F1F2_TO_S/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))

  assert(type(x) == "lVector", "1 input should be a lVector")
  assert(x:has_nulls() == false, "Not set up for null values as yet")
  local x_qtype = assert(x:fldtype())

  assert(type(y) == "lVector", "2 input should be a lVector")
  assert(y:has_nulls() == false, "Not set up for null values as yet")
  local y_qtype = assert(y:fldtype())

  local status, subs = pcall(spfn, x_qtype, y_qtype, optargs)
  assert(status, subs)
  assert(subs.useful)

  local func_name = assert(subs.fn)
  assert(qc[func_name], "Function does not exist " .. func_name)
  local args   = assert(subs.args)
  local getter = assert(subs.getter)
  assert(type(getter) == "function")

  local cst_x_as = subs.x_ctype .. " *"
  local cst_y_as = subs.y_ctype .. " *"
  --==================
  local l_chunk_num = 0
  local lgen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local x_len, x_chunk = x:get_chunk(l_chunk_num)
    local y_len, y_chunk = y:get_chunk(l_chunk_num)
    assert(y_len == x_len)

    if ( not x_len) or ( x_len == 0 )  then return nil end

    local cst_x_chunk = ffi.cast(cst_x_as,  get_ptr(x_chunk))
    local cst_y_chunk = ffi.cast(cst_y_as,  get_ptr(x_chunk))
    local start_time  = qc.RDTSC()
    qc[func_name](cst_x_chunk, x_len, cst_y_chunk, args)
    record_time(start_time, func_name)
    x:unget_chunk(l_chunk_num)
    y:unget_chunk(l_chunk_num)
    l_chunk_num = l_chunk_num + 1
    return args
  end
  return  Reducer ( { gen = lgen, func = getter, value = args} )
end
