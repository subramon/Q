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
  -- create bin_bounds 
  local bb = subs.bin_bounds
  local n_bb = subs.n_bin_bounds
  local bc = subs.bin_counts
  local n_bc = subs.n_bin_counts
  --==================
  local l_chunk_num = 0
  local gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local in_len, in_chunk = invec:get_chunk(chunk_num)
    if ( in_len == 0 ) then 
      subs.bin_bounds:delete()
      return nil  -- indicating eor for Reducer 
    end 
    --==================
    local in_ptr = get_ptr(in_chunk, subs.cast_in_as)
    local start_time = cutils.rdtsc()
    local status = qc[func_name](in_ptr, in_len, bb, n_bb, bc, n_bc)
    assert(status == 0)
    record_time(start_time, func_name)
    invec:unget_chunk(chunk_num)
    l_chunk_num = l_chunk_num + 1
    return subs.count
  end
  local args = {gen = gen, destructor = subs.destructor, 
    func = subs.getter, value = subs.bin_counts}
  return Reducer(args)
end
