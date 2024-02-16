local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local Reducer     = require 'Q/RUNTIME/RDCR/lua/Reducer'
local qc          = require 'Q/UTILS/lua/qcore'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local to_scalar   = require 'Q/UTILS/lua/to_scalar'

return function (x, y, optargs )
  local sp_fn_name = "Q/OPERATORS/BIN_COUNT/lua/bin_count_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, x, y, optargs)
  assert(status, subs)
  qc.q_add(subs); 
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Function does not exist " .. func_name)
  --==================
  local l_chunk_num = 0
  local gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local in_len, in_chunk = x:get_chunk(chunk_num)
    if ( in_len == 0 ) then 
      return nil  -- indicating eor for Reducer 
    end 
    --==================
    local in_ptr = get_ptr(in_chunk, subs.cast_in_as)
    local start_time = cutils.rdtsc()
    local status = qc[func_name](in_ptr, in_len, 
      subs.lb, subs.ub, subs.lock, subs.cnt, subs.nb)
    assert(status == 0)
    record_time(start_time, func_name)
    x:unget_chunk(chunk_num)
    l_chunk_num = l_chunk_num + 1
    return subs.count
  end
  local args = {gen = gen, destructor = subs.destructor, 
    func = subs.getter, value = subs.cnt}
  return Reducer(args)
end
