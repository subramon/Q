local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local expander_ainb = function(op, a, b)
  -- START: verify inputs
  assert(op == "ainb")
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(type(b) == "lVector", "b must be a lVector ")
  local sp_fn_name = "Q/OPERATORS/AINB/lua/ainb_specialize"
  local spfn = assert(require(sp_fn_name))

  -- All of b needs to be evaluated
  -- Check the vector b for eval(), if not then call eval()
  if not b:is_eov() then
    b:eval()
  end
  local blen, bptr, nn_bptr = b:get_all()
  assert(nn_bptr == nil, "Don't support null values")
  assert(blen > 0)
  assert(bptr)

  local b_sort_order = b:get_meta("sort_order")

  local status, subs = pcall(spfn, a:fldtype(), b:fldtype(), blen, b_sort_order)
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)

  -- allocate buffer for output
  local csz = qconsts.chunk_size -- over allocated but needed by C
  local cbuf = nil
  local chunk_idx = 0
  local function ainb_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    cbuf = cbuf or cmem.new(csz)
    local alen, aptr, nn_aptr = a:chunk(chunk_idx) 
    if ( ( not alen ) or ( alen == 0 ) ) then
      return 0, nil, nil
    end
    assert(nn_aptr == nil, "Not prepared for null values in a")
    -- Using get_prt() for aptr and bptr as lVector:chunk() returns CMEM structure 
    local casted_aptr = ffi.cast( qconsts.qtypes[subs.a_qtype].ctype .. "*", get_ptr(aptr))
    local casted_bptr = ffi.cast( qconsts.qtypes[subs.b_qtype].ctype .. "*", get_ptr(bptr))
    local casted_cbuf = ffi.cast( qconsts.qtypes['B1'].ctype .. "*", get_ptr(cbuf))
    local start_time = qc.RDTSC()
    local status = qc[func_name]( casted_aptr, alen, casted_bptr, blen, casted_cbuf)
    record_time(start_time, func_name)
    assert(status == 0, "C error in ainb")
    chunk_idx = chunk_idx + 1
    return alen, cbuf, nil
  end
  return lVector( {gen=ainb_gen, has_nulls=false, qtype="B1"} )
end

return expander_ainb
