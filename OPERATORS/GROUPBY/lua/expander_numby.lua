local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local cVector  = require 'libvctr'
local cutils   = require 'libcutils'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local chunk_size = cVector.chunk_size()
local function expander_numby(a, nb, optargs)
  local sp_fn_name = "Q/OPERATORS/GROUPBY/lua/numby_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(a, nb, optargs))
  local func_name = assert(subs.fn)
  local out_qtype = subs.out_qtype

  qc.q_add(subs); 

  local n_out = chunk_size -- note this is *NOT* nb or nb+1
  -- this is because when we allocate for a Vector, we allocate in chunks
  -- of a given size. This could be wasteful when nb << chunk_size
  -- Might want to reconsider the choice of Vector and consider
  -- a Reducer instead. TODO P3
  local sz_out = n_out * qconsts.qtypes[out_qtype].width
  local chunk_idx = 0
  local out_buf = assert(cmem.new(0))

  local function numby_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( not out_buf:is_data() ) then 
      -- allocate buffer for output
      out_buf = assert(cmem.new(sz_out))
      out_buf:zero() -- particularly important for this operator
      out_buf:stealable(true)
    end
    while true do
      local a_len, a_chunk, _ = a:get_chunk(chunk_idx)
      if a_len == 0 then
        return nb, out_buf
      end
      local cst_a_chunk = get_ptr(a_chunk, subs.cst_in_as)
      local cst_out_buf = get_ptr(out_buf, subs.cst_out_as)
      local start_time = cutils.rdtsc()
      local status = qc[func_name](cst_a_chunk, a_len, cst_out_buf, nb, 
        subs.is_safe)
      record_time(start_time, func_name)
      a:unget_chunk(chunk_idx)
      assert(status == 0, "C error in NUMBY")
      if a_len < chunk_size then -- this is last chunk of a
        return nb, out_buf
      end
      chunk_idx = chunk_idx + 1
    end
  end
  return lVector( { gen = numby_gen, has_nulls = false, qtype = out_qtype } )
end

return expander_numby
