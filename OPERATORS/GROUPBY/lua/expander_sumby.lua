local cmem    = require 'libcmem'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Reducer = require 'Q/RUNTIME/lua/Reducer'

local function expander_sumby(a, b, nb, optargs)
  -- Verification
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(type(b) == "lVector", "b must be a lVector ")
  assert(type(nb) == "number")
  assert( ( nb > 0) and ( nb < qconsts.chunk_size) )
  local sp_fn_name = "Q/OPERATORS/GROUPBY/lua/sumby_specialize"
  local spfn = assert(require(sp_fn_name))
  local c -- condition field 
  local nt = qc.q_omp_get_num_procs() -- number of procs
  -- Get vector size, start with default estimate 
  local na = qconsts.chunk_size 
  if ( a:is_eov() ) then na = a:length() end
  -- decide what nt should be
  local tmp1 = math.sqrt(na) / nb
  if ( nt > tmp1 ) then nt = math.floor(tmp1) end
  if ( nt < 1 ) then nt = 1 end 
  --================

  -- Keeping default is_safe value as true
  -- This will not allow C code to write values at incorrect locations
  local is_safe = true
  if optargs then
    assert(type(optargs) == "table")
    if ( optargs["is_safe"] == false ) then
      is_safe =  optargs["is_safe"]
      assert(type(is_safe) == "boolean")
    end
    if ( optargs.where ) then
      c = optargs.where
      assert(type(c) == "lVector")
      assert(c:fldtype() == "B1")
    end
  end

  local status, subs, tmpl = pcall(spfn, a:fldtype(), b:fldtype(), c)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation

  assert(qc[func_name], "Symbol not defined " .. func_name)
  -- following jiggery is so that each core's buffer is 
  -- spaced sufficiently far away to avoid false sharing
  local n_buf_per_core = math.ceil((nb / 64 )) * 64
  local width = qconsts.qtypes[subs.out_qtype].width
  local sz_out_in_bytes = n_buf_per_core * nt * width
  local chunk_idx = 0

      -- allocate buffer for output
  local out_buf = assert(cmem.new(sz_out_in_bytes))
  out_buf:zero()
  assert(type(out_buf) == "CMEM")
  
  local a_ctype = qconsts.qtypes[a:fldtype()].ctype 
  local b_ctype = qconsts.qtypes[b:fldtype()].ctype 
  local out_ctype = qconsts.qtypes[subs.out_qtype].ctype 
  local cst_out_buf = ffi.cast( out_ctype .. "*",  get_ptr(out_buf))
  
  local vectorizer = function(value)
    assert(type(value) == "CMEM")
    local v = lVector.new(
    {qtype = subs.out_qtype, gen = true, has_nulls = false})
    v:put_chunk(value, nil, nb)
    v:eov()
    return v
  end
  local function sumby_gen(chunk_num)
    assert(chunk_num == chunk_idx)

    --=============================================
    local a_len, a_chunk, a_nn_chunk = a:chunk(chunk_idx)
    local b_len, b_chunk, b_nn_chunk = b:chunk(chunk_idx)
    local c_len, c_chunk, c_nn_chunk 
    if ( c ) then 
      c_len, c_chunk, c_nn_chunk = c:chunk(chunk_idx)
    end
    assert(a_len == b_len)
    assert(a_nn_chunk == nil, "Null is not supported")
    assert(b_nn_chunk == nil, "Null is not supported")
    if ( chunk_idx == 0 ) then assert(a_len > 0 ) end
    --=============================================
    
    local cst_a_chnk = ffi.cast( a_ctype .. "*",  get_ptr(a_chunk))
    local cst_b_chnk = ffi.cast( b_ctype .. "*",  get_ptr(b_chunk))
    local cst_c_chunk  = nil
    if ( c ) then 
      cst_c_chunk = ffi.cast( "uint64_t *",    get_ptr(c_chunk))
    end
    local status = qc[func_name](
        cst_a_chnk, a_len, cst_b_chnk, 
        cst_out_buf, nb, nt, n_buf_per_core, 
        cst_c_chunk, is_safe)
    assert(status == 0, "C error in SUMBY")
    if ( a_len < qconsts.chunk_size ) then 
      local status = qc[func_name](
        nil, 0, nil,
        cst_out_buf, nb, nt, n_buf_per_core, 
        nil, false)
      assert(status == 0, "C error in SUMBY")
      return nil
    end
    chunk_idx = chunk_idx + 1
    return true
  end
  local s =  Reducer ( { gen = sumby_gen, func = vectorizer, value = out_buf} )
  return s
end

return expander_sumby
