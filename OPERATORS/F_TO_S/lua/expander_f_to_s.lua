local cutils    = require 'libcutils'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local Reducer   = require 'Q/RUNTIME/RDCR/lua/Reducer'
local qc        = require 'Q/UTILS/lua/q_core'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local cVector   = require 'libvctr'

return function (a, x)
  assert(type(x) == "lVector", "input should be a lVector")
  assert(x:has_nulls() == false, "Not set up for null values as yet")
  local x_qtype = assert(x:fldtype())

  local sp_fn_name = "Q/OPERATORS/F_TO_S/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, x_qtype)
  assert(status, "Failure of specializer " .. sp_fn_name)
  assert(type(subs) == "table")

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
  subs.incs = { "UTILS/inc", "OPERATORS/F_TO_S/inc/", "OPERATORS/F_TO_S/gen_inc/", }
  subs.structs = { "OPERATORS/F_TO_S/inc/minmax_struct.h",
                   "OPERATORS/F_TO_S/inc/sum_struct.h", 
                   "RUNTIME/SCLR/inc/scalar_struct.h" }
  qc.q_add(subs)


  local reduce_struct = assert(subs.args)
  local getter        = assert(subs.getter)
  assert(reduce_struct)
  assert(type(getter) == "function")
  --==================
  local cast_x_as = subs.in_ctype .. " *"
  local is_eor = false
  local l_chunk_num = 0
  local chunk_size = cVector.chunk_size()
  --==================
  local lgen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local offset = l_chunk_num * chunk_size
    local x_len, x_chunk, nn_x_chunk = x:get_chunk(l_chunk_num)
    if ( ( not x_len ) or ( x_len == 0 ) ) then return nil end 
    local inx = get_ptr(x_chunk, cast_x_as)
    local start_time = cutils.rdtsc()
    qc[func_name](inx, x_len, reduce_struct, offset)
    record_time(start_time, func_name)
    x:unget_chunk(l_chunk_num)
    l_chunk_num = l_chunk_num + 1
    if ( x_len < chunk_size ) then is_eor = true  end
    return reduce_struct, is_eor
  end
  local s =  Reducer ( { gen = lgen, func = getter, value = reduce_struct} )
  return s
end
