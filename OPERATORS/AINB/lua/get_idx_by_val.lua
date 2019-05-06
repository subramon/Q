local Q = require 'Q/q_export'
local qc = require 'Q/UTILS/lua/q_core'
local lVector     = require 'Q/RUNTIME/lua/lVector'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local ffi         = require 'Q/UTILS/lua/q_ffi'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local cmem        = require 'libcmem'
local Scalar      = require 'libsclr'

local function get_idx_by_val(x, y, optargs)
  assert(x and type(x) == "lVector", "x must be a Vector")
  assert(y and type(y) == "lVector", "y must be a Vector")
  if ( not y:is_eov() ) then y:eval() end 
  assert(y:is_eov(), "y must be materialized")

  local sp_fn_name = "Q/OPERATORS/AINB/lua/get_idx_by_val_specialize"
  local spfn = assert(require(sp_fn_name))
  local null_val
  local nR2 = y:length()
  local sort_order = y:get_meta("sort_order")
  if ( sort_order == nil ) then 
    -- check if sorted ascending
    local is_asc = Q.is_next(y, "geq"):eval()
    assert(is_asc == true, "Y needs to be sorted ascending")
    -- TODO Following needs to be done by is_next, not by us
    y:set_meta('sort_order', "asc")
  end
  assert(sort_order ~= "asc", "Y needs to be sorted ascending")
  if ( not optargs ) then
    optargs = {}
  end
  optargs.nR2 = nR2
  optargs.sort_order = sort_order
  local status, subs, tmpl = pcall(spfn, x:fldtype(), y:fldtype(), 
    optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic Compilation
  assert(qc[func_name], "Symbol not available" .. func_name)

  local lb2 = Scalar.new(0, "I8")

  local f3_qtype = assert(subs.idx_qtype)
  local f3_width = qconsts.qtypes[f3_qtype].width
  local buf_sz = qconsts.chunk_size * f3_width
  local f3_buf = nil

  local first_call = true
  local chunk_idx = 0
  local myvec 

  -- f2 is same in each chunk call of f3_gen
  local f2_len, f2_ptr = y:get_all()
  assert(f2_len == nR2)
  local f2_cast_as = subs.val_ctype .. "*"
  local ptr2 = ffi.cast(f2_cast_as,  get_ptr(f2_ptr))

  local f3_gen = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      first_call = false
      f3_buf = assert(cmem.new(buf_sz, f3_qtype))
      myvec:no_memcpy(f3_buf) -- hand control of this f3_buf to the vector 
    else
      myvec:flush_buffer() -- tell the vector to flush its buffer
    end
    assert(f3_buf)
    local f3_cast_as = subs.idx_ctype .. "*"

    local f1_len, f1_chunk, nn_f1_chunk
    f1_len, f1_chunk, nn_f1_chunk = x:chunk(chunk_idx)
    local f1_cast_as = subs.val_ctype .. "*"

    if f1_len > 0 then
      local chunk1 = ffi.cast(f1_cast_as,  get_ptr(f1_chunk))
      local chunk3 = ffi.cast(f3_cast_as,  get_ptr(f3_buf))
      local start_time = qc.RDTSC()
      qc[func_name](chunk1, f1_len, ptr2, nR2, chunk3)
      -- TODO record_time(start_time, func_name)
    else
      f3_buf = nil
    end
    chunk_idx = chunk_idx + 1
    return f1_len, f3_buf
  end
  myvec = lVector{gen=f3_gen, nn=false, qtype=f3_qtype, has_nulls=false}
  return myvec
end

return require('Q/q_export').export('get_idx_by_val', get_idx_by_val)
