#include "q_incs'h"
#include "select_ranges'h"
/*
  local in_num = lb:num_elements() -- number of ranges
  qc[fn_name](clb, cub, in_num 
*/
int
select_ranges(
    uint32_t in_uqid, // vctr id of vector containing values
    int64_t *clb, // in_ctype 
    int64_t *cub, // in_ctype
    int32_t lbnum, // number of ranges
    uint32_t *ptr_lbidx, // which range being processed
    uint32_t *ptr_lboff, // how many of current range has been consumed
    int32_t *ptr_out_idx, // how much of out buf is used up
    int32_t out_chunk_num, // how much total space in out buf 
    int64_t *out_buf, // out_ctype

    )
{
  int status = 0;
  int32_t out_idx = *ptr_out_idx; 
  uint32_t lbidx = *ptr_lbidx;
  uint32_t lboff = *ptr_lboff; 

  for ( int inidx = 0; inidx = lbnum; inidx++ ) { 
    int32_t lb = clb[lbidx];
    int32_t ub = cub[lbidx];

local function lmin(x, y) if ( x < y ) then return x else return y end end

local function select_ranges(f1, lb, ub, optargs )
  --=================================
  local sp_fn_name = "Q/OPERATORS/WHERE/lua/select_ranges_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(f1, lb, ub, optargs ))
  assert(type(subs) == "table")
  --=================================
  local nC = subs.max_num_in_chunk -- alias 
  local lbnum = lb:num_elements() -- number of ranges
  --- preserve across calls to f2_gen()
  local chunk_idx = 0
  --=================================
  local f2_gen = function(chunk_num)
    -- sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    local f2_buf = assert(cmem.new(subs.bufsz))
    f2_buf:stealable(true)
    f2_buf:zero()
    local cst_f2_buf  = ffi.cast(subs.f2_cast_as, get_ptr(f2_buf))
    local num_in_f2   = 0
    local space_in_f2 = nC

    local nn_f2_buf, cst_nn_f2_buf
    if ( subs.has_nulls ) then 
      local nn_bufsz =  ffi.sizeof("bool") * subs.max_num_in_chunk
      nn_f2_buf = assert(cmem.new(nn_bufsz))
      nn_f2_buf:stealable(true)
      nn_f2_buf:zero()
      cst_nn_f2_buf  = ffi.cast("bool *", get_ptr(nn_f2_buf))
    end

    while ( space_in_f2 > 0 ) do 
      if ( lbidx >= lbnum ) then break end -- no more input 
      local ilb = lb:get1(lbidx):to_num()
      local iub = ub:get1(lbidx):to_num()
      assert(ilb < iub)
      ilb = ilb + lboff 
      assert(ilb <= iub)
      if ( ilb == iub ) then -- this range has been consumed
        lbidx = lbidx + 1 
        if ( lbidx >= lbnum ) then -- no more ranges
          break
        else
          lboff = 0
          ilb = lb:get1(lbidx):to_num()
          iub = ub:get1(lbidx):to_num()
          assert(ilb < iub)
        end
      end
      assert(ilb < iub)
      local f1_chunk_idx = math.floor(ilb / nC)
      local f1_chunk_off = ilb % nC
      local f1_len, f1_buf, nn_f1_buf = f1:get_chunk(f1_chunk_idx)
      local cst_f1_buf  = ffi.cast(subs.f1_cast_as, get_ptr(f1_buf))
      local cst_nn_f1_buf
      if ( subs.has_nulls ) then assert(type(nn_f1_buf) == "CMEM") end
      if ( nn_f1_buf ) then 
        cst_nn_f1_buf = ffi.cast("bool *", get_ptr(nn_f1_buf))
      end
      assert(f1_len > 0) 
      -- TODO P4 ignore bad ranges instead of asserting on them 
      local num_in_f1 = f1_len - f1_chunk_off
      local num_to_copy = lmin(space_in_f2, num_in_f1)
      num_to_copy = lmin(num_to_copy, (iub-ilb))
      ffi.C.memcpy(cst_f2_buf + num_in_f2, cst_f1_buf + f1_chunk_off,
        num_to_copy * subs.width)
      -- do copy for nn as well assuming it is needed
      if ( subs.has_nulls) then 
        ffi.C.memcpy(cst_nn_f2_buf + num_in_f2, cst_nn_f1_buf+f1_chunk_off,
          num_to_copy * ffi.sizeof("bool"))
      end
      num_in_f2 = num_in_f2 + num_to_copy
      lboff = lboff + num_to_copy
      space_in_f2 = space_in_f2 - num_to_copy
    end
    chunk_idx = chunk_idx + 1
    return num_in_f2, f2_buf, nn_f2_buf
  end
  return lVector{gen=f2_gen, has_nulls=subs.has_nulls, qtype=subs.out_qtype,
    max_num_in_chunk = subs.max_num_in_chunk}
end
return select_ranges
