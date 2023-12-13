-- Provides a slow but easy way to convert a string into a number
local qc            = require 'Q/UTILS/lua/qcore'
local ffi           = require 'ffi'
local cmem          = require 'libcmem'
local cutils        = require 'libcutils'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local lVector       = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qcfg          = require 'Q/UTILS/lua/qcfg'
local function SC_to_CUSTOM1(
  invec, 
  optargs 
  )
  local specializer = "Q/OPERATORS/LOAD_CSV/lua/custom1_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(invec))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  local l_chunk_num = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    local out_buf = cmem.new({ size = subs.bufsz, qtype = subs.out_qtype})
    out_buf:zero()
    out_buf:stealable(true)

    local out_ptr = get_ptr(out_buf, subs.cast_out_as)
    local in_len, in_chunk = invec:get_chunk(l_chunk_num)
    assert(type(len) == "number")
    if ( len == 0 ) then 
      buf:delete()
      return 0, nil 
    end 
    --====================================
    local in_ptr = get_ptr(in_chunk, subs.cast_in_as)
    local status = qc[fn](in_ptr, in_len, subs.in_width, out_ptr);
    assert(status == 0)
    invec:unget_chunk(l_chunk_num)
    if ( in_len < subs.max_num_in_chunk ) then 
      invec:kill()
    end 
    l_chunk_num = l_chunk_num + 1
    return in_len, out_buf
  end
  local vargs = {}
  vargs.gen = gen
  vargs.qtype = subs.out_qtype
  vargs.has_nulls = false
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vctr_args)
end
return require('Q/q_export').export('SC_to_CUSTOM1', SC_to_CUSTOM1)
