local qconsts   = require 'Q/UTILS/lua/q_consts'
local Reducer   = require 'Q/RUNTIME/lua/Reducer'
local ffi       = require 'ffi'
local qc        = require 'Q/UTILS/lua/q_core'
local chk_chunk = require 'Q/UTILS/lua/chk_chunk'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

return function (a, x)
  assert(type(x) == "lVector", "input should be a lVector")
  assert(x:has_nulls() == false, "Not set up for null values as yet")
  local x_qtype = assert(x:fldtype())

  local sp_fn_name = "Q/OPERATORS/F_TO_S/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, x_qtype)
  assert(type(subs) == "table")
  assert(status, "Failure of specializer " .. sp_fn_name)

  -- Return early if you have cached the result of a previous call
  if ( x:is_eov() ) then 
    -- Note that reserved keywords are prefixed by __
    -- For example, minval is stored with key = "__min"
    local rslt = x:get_meta("__" .. a)
    if ( rslt ) then 
      assert(type(rslt) == "table") 
      local extractor = function (tbl) return unpack(tbl) end
      return Reducer ({value = rslt, func = extractor})
    end
  end

  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Function does not exist " .. func_name)

  local reduce_struct = assert(subs.args)
  local getter        = assert(subs.getter)
  assert(reduce_struct)
  assert(type(getter) == "function")
  local cast_x_as = subs.in_ctype .. " *"
  --==================
  local l_chunk_num = 0
  local lgen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local offset = l_chunk_num * qconsts.chunk_size
    local x_len, x_chunk, nn_x_chunk = x:chunk(l_chunk_num)
    if ( ( not x_len ) or ( x_len == 0 ) ) then return nil end 
    local inx = ffi.cast(cast_x_as, get_ptr(x_chunk))
    local start_time = qc.RDTSC()
    qc[func_name](inx, x_len, reduce_struct, offset)
    record_time(start_time, func_name)
    l_chunk_num = l_chunk_num + 1
    return reduce_struct
  end
  local s =  Reducer ( { gen = lgen, func = getter, value = reduce_struct} )
  return s
end
