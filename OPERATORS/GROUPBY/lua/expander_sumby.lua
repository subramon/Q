local cmem    = require 'libcmem'
local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc      = require 'Q/UTILS/lua/qcore'
local Reducer = require 'Q/RUNTIME/RDCR/lua/Reducer'

local function expander_sumby(operator, val, grp, nb, cnd, optargs)
  if ( type(optargs) == "nil" ) then optargs = {} end
  optargs.operator = operator
  local sp_fn_name = "Q/OPERATORS/GROUPBY/lua/sumby_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs = pcall(spfn, val, grp, nb, cnd, optargs)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)

  -- START: Dynamic compilation
  local func_name = assert(subs.fn)
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  assert(qc[func_name], "Symbol not defined " .. func_name)
  -- STOP: Dynamic compilation

  -- allocate buffer for output
  local out_val_buf = assert(cmem.new(subs.out_val_buf_size))
  out_val_buf:zero() -- IMPORTANT 
  out_val_buf:stealable(true) 
  local cast_out_val_buf = get_ptr(out_val_buf, subs.cast_out_val_as)

  local out_cnt_buf = assert(cmem.new(subs.out_cnt_buf_size))
  out_cnt_buf:zero() -- IMPORTANT 
  out_cnt_buf:stealable(true) 
  local cast_out_cnt_buf = get_ptr(out_cnt_buf, subs.cast_out_cnt_as)

  local vectorizer = function(rdcr_val)
    assert(type(rdcr_val) == "table")
    
    local r_out_val_buf = rdcr_val[1]
    assert(type(r_out_val_buf) == "CMEM")
    local vval = lVector.new(
    {qtype = subs.out_val_qtype, gen = true, has_nulls = false})
    vval:put_chunk(r_out_val_buf, nb)
    vval:eov()

    local r_out_cnt_buf = rdcr_val[2]
    assert(type(r_out_cnt_buf) == "CMEM")
    local vcnt = lVector.new(
    {qtype = subs.out_cnt_qtype, gen = true, has_nulls = false})
    vcnt:put_chunk(r_out_cnt_buf, nb)
    vcnt:eov()

    return vval, vcnt
  end
  local chunk_idx = 0
  local function sumby_gen(chunk_num)
    assert(chunk_num == chunk_idx)
    --=============================================
    local val_len, val_chunk = val:get_chunk(chunk_idx)
    local grp_len, grp_chunk = grp:get_chunk(chunk_idx)
    local cnd_len, cnd_chunk
    local cast_cnd_chunk = ffi.NULL
    if ( cnd ) then 
      cnd_len, cnd_chunk = cnd:get_chunk(chunk_idx)
    end
    assert(val_len == grp_len)
    if ( chunk_idx == 0 ) then assert(val_len > 0 ) end
    if ( val_len == 0 ) then return nil end 
    --=============================================
    local cast_val_chnk = get_ptr(val_chunk, subs.cast_val_fld_as)
    local cast_grp_chnk = get_ptr(grp_chunk, subs.cast_grp_fld_as)
    if ( cnd ) then 
      assert(val_len == cnd_len)
      cast_cnd_chunk = get_ptr(cnd_chunk, subs.cast_cnd_fld_as)
    end
    --=============================================
    local status = qc[func_name](
        cast_val_chnk, val_len, cast_grp_chnk, cast_cnd_chunk, 
        cast_out_val_buf, cast_out_cnt_buf, nb)
    assert(status == 0, "C error in SUMBY")
    val:unget_chunk(chunk_idx)
    grp:unget_chunk(chunk_idx)
    if ( cnd ) then 
      cnd:unget_chunk(chunk_idx)
    end
    if ( val_len < val:max_num_in_chunk() ) then 
      return nil
    end
    chunk_idx = chunk_idx + 1
    return { out_val_buf, out_cnt_buf}
  end
  local rargs = {}
  rargs.gen = sumby_gen
  rargs.func = vectorizer
  rargs.value = { out_val_buf, out_cnt_buf}
  local r =  Reducer (rargs)
  return r
end

return expander_sumby
