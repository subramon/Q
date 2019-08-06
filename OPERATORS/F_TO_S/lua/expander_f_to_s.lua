local qconsts = require 'Q/UTILS/lua/q_consts'
local Reducer = require 'Q/RUNTIME/lua/Reducer'
local ffi = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local chk_chunk      = require 'Q/UTILS/lua/chk_chunk'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

return function (a, x, y, optargs )
  local sp_fn_name = "Q/OPERATORS/F_TO_S/lua/" .. a .. "_specialize"
  local mem_init_name = "Q/OPERATORS/F_TO_S/lua/" .. a .. "_mem_initialize"
  local spfn = assert(require(sp_fn_name), "Specializer missing " .. sp_fn_name)
  local mem_initialize = assert(require(mem_init_name), "mem_initializer not found")

  assert(type(x) == "lVector", "input should be a lVector")
  assert(x:has_nulls() == false, "Not set up for null values as yet")
  local x_qtype = assert(x:fldtype())
  local status, subs, tmpl = pcall(spfn, x_qtype, y, optargs)
  assert(status, "Failure of specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  if ( x:is_eov() ) then 
    local rslt = x:get_meta(a)
    if ( rslt ) then 
      assert(type(rslt) == "table") 
      local extractor = function (tbl) return unpack(tbl) end
      return Reducer ({value = rslt, func = extractor})
    end
  end

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Function does not exist " .. func_name)

  -- calling mem_initializer
  local reduce_struct, cst_as, getter = mem_initialize(subs)
  assert(reduce_struct)
  assert(getter)
  assert(type(getter) == "function")
  --==================
  local is_early_exit = false
  local chunk_idx = 0
  local lgen = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    local idx = chunk_idx * qconsts.chunk_size
    local x_len, x_chunk, nn_x_chunk = x:chunk(chunk_idx)
    assert(chk_chunk(x_len, x_chunk, nn_x_chunk))
    chunk_idx = chunk_idx + 1
    if x_len and ( x_len > 0 ) and ( is_early_exit == false ) then
      local casted_x_chunk = ffi.cast( qconsts.qtypes[x:fldtype()].ctype .. "*",  get_ptr(x_chunk))
      local casted_struct = ffi.cast(cst_as, get_ptr(reduce_struct))
      local start_time = qc.RDTSC()
      qc[func_name](casted_x_chunk, x_len, casted_struct, idx)
      record_time(start_time, func_name)
      if ( a == "is_next" ) then
        local X = ffi.cast(cst_as, reduce_struct)
        if ( tonumber(X[0].is_violation) == 1 ) then 
          is_early_exit = true 
        end
      end
      return reduce_struct
    end
  end
  local s =  Reducer ( { gen = lgen, func = getter, value = reduce_struct} )
  return s
end
