local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc       = require 'Q/UTILS/lua/qcore'
local cmem     = require 'libcmem'
local cVector  = require 'libvctr'
local cutils   = require 'libcutils'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_numby(a, nb, optargs)
  if ( not optargs ) then optargs = {} end 
  assert(type(optargs) == "table")
  -- nb is a number and we assume that the value of a are in
  -- [0 .. nb-1 ]
  local sp_fn_name = "Q/OPERATORS/GROUPBY/lua/numby_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(a, nb, optargs))
  local func_name = assert(subs.fn)

  qc.q_add(subs); 

  local n_out = subs.max_num_in_chunk 
 -- note this is *NOT* nb or nb+1
  -- this is because when we allocate for a Vector, we allocate in chunks
  -- of a given size. This could be wasteful when nb << max_num_in_chunk
  -- Might want to reconsider the choice of Vector and consider
  -- a Reducer instead. 
  -- TODO P2 I think it is okay for n_out to be nb. Try it out 
  local sz_out = n_out * cutils.get_width_qtype(subs.out_qtype)
  local chunk_idx = 0
  local out_buf = assert(cmem.new(sz_out))
  out_buf:zero() -- particularly important for this operator
  out_buf:stealable(true)
  local a_max_num_in_chunk = a:max_num_in_chunk()

  local function numby_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    while true do
      local a_len, a_chunk, _ = a:get_chunk(chunk_idx)
      if a_len == 0 then
        return nb, out_buf
      end
      local cast_a_chunk = get_ptr(a_chunk, subs.cast_in_as)
      local cast_out_buf = get_ptr(out_buf, subs.cast_out_as)
      local start_time = cutils.rdtsc()
      local status = qc[func_name](cast_a_chunk, a_len, cast_out_buf, nb)
      record_time(start_time, func_name)
      a:unget_chunk(chunk_idx)
      assert(status == 0, "C error in NUMBY")
      if a_len < a_max_num_in_chunk then -- this is last chunk of a
        return nb, out_buf
      end
      chunk_idx = chunk_idx + 1
    end
  end
  local vargs = optargs
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  vargs.gen = numby_gen
  vargs.has_nulls = false
  vargs.qtype = subs.out_qtype 
  return lVector(vargs)
end

return expander_numby
