local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local Reducer     = require 'Q/RUNTIME/RDCR/lua/Reducer'
local qc          = require 'Q/UTILS/lua/qcore'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local to_scalar   = require 'Q/UTILS/lua/to_scalar'

return function (a, invec, sclr, optargs )
  local sp_fn_name = "Q/OPERATORS/COUNT/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, invec, sclr, optargs)
  assert(status, subs)
  qc.q_add(subs); 
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Function does not exist " .. func_name)
  local c_sclr = ffi.cast("SCLR_REC_TYPE *", subs.sclr)
  c_sclr = c_sclr[0].val[string.lower(subs.qtype)]
  --==================
  local l_chunk_num = 0
  local gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local in_len, in_chunk = invec:get_chunk(chunk_num)
    if ( in_len == 0 ) then return nil end 
    --==================
    local in_ptr = get_ptr(in_chunk, subs.cast_in_as)
    local start_time = cutils.rdtsc()
    qc[func_name](in_ptr, in_len, c_sclr, get_ptr(subs.count, "uint64_t *"))
    record_time(start_time, func_name)
    invec:unget_chunk(chunk_num)
    l_chunk_num = l_chunk_num + 1
    return subs.count
  end
  local args = {gen = gen, destructor = subs.destructor, 
    func = subs.getter, value = subs.count}
  return Reducer(args)
end
