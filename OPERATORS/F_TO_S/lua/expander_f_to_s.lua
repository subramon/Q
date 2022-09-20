local cutils      = require 'libcutils'
local Reducer     = require 'Q/RUNTIME/RDCR/lua/Reducer'
local qc          = require 'Q/UTILS/lua/qcore'
local qcfg        = require 'Q/UTILS/lua/qcfg'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local max_num_in_chunk       = qcfg.max_num_in_chunk

return function (a, x, optargs)
  -- Return early if you have cached the result of a previous call
  if ( x:is_eov() ) then 
    -- Note that reserved keywords are prefixed by __
    -- For example, minval is stored with key = "__min"
    local rslt = x:get_meta(a)
    if ( rslt ) then 
      assert(type(rslt) == "table") 
      local extractor = function (tbl) return unpack(tbl) end
      return Reducer ({value = rslt, func = extractor})
    end
  end

  local sp_fn_name = "Q/OPERATORS/F_TO_S/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(x, optargs))
  -- subs must return (1) args (2) getter ..... TODO P3 finish doc
  local func_name = assert(subs.fn)
  local accumulator = assert(subs.accumulator)
  assert(type(accumulator) == "CMEM")

  qc.q_add(subs)

  local accumulator      = assert(subs.accumulator)
  local cast_accumulator_as = assert(subs.cast_accumulator_as)
  local c_accumulator    = assert(get_ptr(accumulator, cast_accumulator_as))
  local getter           = assert(subs.getter)
  assert(type(getter) == "function")
  --==================
  local is_eor = false -- eor = End Of Reducer
  local l_chunk_num = 0
  --==================
  local lgen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local offset = l_chunk_num * max_num_in_chunk
    local x_len, x_chunk, nn_x_chunk = x:get_chunk(l_chunk_num)
    if ( ( not x_len ) or ( x_len == 0 ) ) then return nil end 
    local c_in = get_ptr(x_chunk, subs.cast_in_as)
    local start_time = cutils.rdtsc()
    qc[func_name](c_in, x_len, c_accumulator, offset)
    record_time(start_time, func_name)
    x:unget_chunk(l_chunk_num)
    l_chunk_num = l_chunk_num + 1
    if ( x_len < max_num_in_chunk ) then is_eor = true  end
    return accumulator, is_eor 
  end
  return Reducer ( { gen = lgen, func = getter, value = accumulator} )
end
