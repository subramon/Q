-- Inputs are 
-- (a) a table of keys 
-- (2) val_vec, a vector representing value being aggregated
-- (Note that we currently do NOT support aggregation of multiple values
-- Output is 
-- (1) a Vector representing the composite key
-- (2) a Vector representing the value (obtained from Vin)

local function min(x, y) if ( x < y ) then return x else return y end  end

local function mk_comp_key_val(Tk, in_val_vec)
  local Q           = require 'Q/q_export'
  local lVector     = require 'Q/RUNTIME/lua/lVector'
  local qc          = require 'Q/UTILS/lua/q_core'
  local get_ptr     = require 'Q/UTILS/lua/get_ptr'
  local record_time = require 'Q/UTILS/lua/record_time'
  local get_nDR     = require 'Q/OPERATORS/MDB/lua/get_nDR'
  local mk_template = require 'Q/OPERATORS/MDB/lua/mk_template'
  local qconsts     = require 'Q/UTILS/lua/q_consts'
  local ffi         = require 'Q/UTILS/lua/q_ffi'
  local cmem        = require 'libcmem'

  -- START: Basic checks on input 
  nDR, in_vecs = get_nDR(Tk)
  -- currently only one value can be aggregated
  assert(type(in_val_vec) == "lVector") 
  local val_type = in_val_vec:fldtype()
  assert ((val_type == "I1") or (val_type == "I2") or (val_type == "I4") or 
          (val_type == "I8") or (val_type == "F4") or (val_type == "F8") )
  assert(type(Tk) == "table")
  local template, nR, nD, nC = mk_template(nDR)
  for i = 1, nD do 
    assert(type(in_vecs[i] == "lVector"))
  end
  --===================================================================
  -- START: Specialization
  local spfn = require("Q/OPERATORS/MDB/lua/mk_comp_key_val_specialize" )
  local status, subs, tmpl = pcall(spfn, val_type)
  assert(status, "error: mk_comp_key_val_specialize()")
  assert(type(subs) == "table", "error: mk_comp_key_valsort_specialize()")
  local func_name = assert(subs.fn)

  local cast_in_vec_as = qconsts.qtypes[val_type].ctype .. " *"
  --===================================================================
  -- START: Get function pointer
  local fnptr
  local unit_testing = true
  if ( unit_testing ) then 
    -- NOTE: Control does not come here in production usage
    local ffi = require 'ffi' -- NOTE: Following cdef hard coded 
    ffi.cdef([[
extern int
mk_comp_key_val_F4(
    int **template, /* [nR][nC] */
    int nR,
    int nC,
    /* 0 <= template[i][j] < nD */
    uint8_t **in_dim_vals, /* [nD][nV] */
    float *in_in_vec_val, /* [nV] */
    uint64_t *out_key, /*  [nK] */ 
    float *out_val, /*  [nK] */
    int nV,
    int nK
    );
    ]])
    local x = ffi.load("libmdb.so") -- NOTE: Check .so in proper directory
    fnptr = assert(x[func_name], "Missing symbol " .. func_name)
  else
    -- START: Dynamic compilation
    if ( not qc[func_name] ) then
      print("Dynamic compilation kicking in... ")
      qc.q_add(subs, tmpl, func_name)
    end
    -- STOP: Dynamic compilation
    fnptr = assert(qc[func_name], "Missing symbol " .. func_name)
  end
  --===================================================================
  -- START Allocate necessary buffers
  --==============================================
  -- Unlike usual pattern, we are pre-allocating buffers
  -- Usually, we wait for first call to do so 
  local nK = qconsts.chunk_size 

  local key_type = "I8" -- HARD CODED
  local key_cast_as = "uint64_t * " -- HARD CODED
  local key_width = qconsts.qtypes[key_type].width
  local key_buf = cmem.new(nK * key_width, key_type)
  local cst_key_buf = assert(ffi.cast(key_cast_as, get_ptr(key_buf)))
  local bak_cst_key_buf = cst_key_buf -- because key_buf is changeable

  local val_ctype = qconsts.qtypes[val_type].ctype
  local val_cast_as = val_ctype .. " * "
  local val_width = qconsts.qtypes[val_type].width
  local val_buf = cmem.new(nK * val_width, val_type)
  local cst_val_buf = assert(ffi.cast(val_cast_as, get_ptr(val_buf)))
  local bak_val_buf = val_buf -- because val_buf is changeable
  local bak_cst_val_buf = cst_val_buf -- because val_buf is changeable

  --==============================================
  local c_in_dim_vals = ffi.cast("uint8_t **",
    get_ptr(cmem.new(nD * ffi.sizeof("uint8_t *"))))
  --==============================================
  local chunk_idx = 0
  local in_chunk_idx = -1 -- because incremented before used
  local M = { "key", "val" } -- names of 2 generators we will produce
  local num_vals_to_consume = 0 
  local num_keys_that_can_be_produced = nK
  local len   = {}
  local chunk = {}
  lgens = {} -- we make a table of two generators 
  local c_in_vec_val
  for _, vecname in pairs(M) do 
    local function kv_gen(chunk_num)
      assert(chunk_num == chunk_idx)
::get_more_input::
      local in_vec_len, in_vec_chunk 
      if ( num_vals_to_consume == 0 ) then 
        in_chunk_idx = in_chunk_idx + 1 
        for i = 1, nD do 
          len[i], chunk[i] = in_vecs[i]:chunk(in_chunk_idx)
        end
        in_vec_len, in_vec_chunk = in_val_vec:chunk(in_chunk_idx)
        -- Check that all input vectors behave similarly
        for i = 2, nD do 
          assert(len[i] == len[1] )
          if ( chunk[1] == nil ) then assert(chunk[i] == nil) end 
          if ( chunk[1] ~= nil ) then assert(chunk[i] ~= nil) end 
        end
        assert(len[1] == in_vec_len)
        --==============================
        -- If no more values, then signal end of vector
        num_vals_to_consume = len[1]
        if ( num_vals_to_consume == 0 ) then 
          if ( vecname == "key" ) then 
            val_vec:eov()
          elseif ( vecname == "val" ) then 
            key_vec:eov()
          end
          if ( num_keys_produced == 0 ) then 
            return 0, nil
          else
            -- Create a CMEM and set the pointer as foreign 
            -- do not use key_buf, val_buf since they point to start
            -- of buffers which may or may not be the right thing to do
            if ( vecname == "key" ) then 
              return num_keys_produced, key_buf
            elseif ( vecname == "val" ) then 
              return num_keys_produced, val_buf
            end
          end
        end
      end
      --==============
      -- Cast input the way C needs it 
      for i = 1, nD do 
        c_in_dim_vals[i-1] = ffi.cast("uint8_t *", get_ptr(chunk[i]))
      end
      c_in_vec_val = ffi.cast(cast_in_vec_as, get_ptr(in_vec_chunk))
      assert(c_in_vec_val)
      --==============
      num_vals_consumed = min(
        num_vals_to_consume, math.floor(num_keys_that_can_be_produced/nR))
      num_keys_produced = num_vals_consumed * nR
      local start_time = qc.RDTSC()
      local status = fnptr(template, nR, nC, c_in_dim_vals, c_in_vec_val, 
         cst_key_buf, cst_val_buf, 
         num_vals_consumed, num_keys_that_can_be_produced)
      record_time(start_time, func_name)
      assert(status == 0)

      num_keys_that_can_be_produced = num_keys_that_can_be_produced 
          - num_keys_produced
      num_vals_to_consume = num_vals_to_consume  - num_vals_consumed
      -- advance pointers depending on how much consumed
      for i = 1, nD do 
        c_in_dim_vals[i-1] = c_in_dim_vals[i-1] + num_vals_consumed
      end
      c_in_vec_val = c_in_vec_val + num_vals_consumed
      if ( num_keys_that_can_be_produced < nR ) then 
        -- reset buffers because we are about to flush them
        num_keys_that_can_be_produced = nK
        cst_vec_buf = bak_cst_vec_buf
        cst_key_buf = bak_cst_key_buf
        -- flush the buffers for output key/val vectors
        -- here's a bit of trickery needed to handle the case that the 
        -- vectors are produced at the same time and are not independent
        chunk_idx = chunk_idx + 1 
        local len = num_keys_produced
        num_keys_produced  = 0
        if ( vecname == "key" ) then 
          val_vec:put_chunk(val, nil, len)
          return len, key_buf
        elseif ( vecname == "val" ) then 
          key_vec:put_chunk(val, nil, len)
          return len, val_buf
        end
      else
        goto get_more_input -- TODO P4 This is ugly. 
      end
      --===========================
    end
    lgens[vecname] = kv_gen
  end
  key_vec = lVector( {gen = lgens.key, has_nulls = false, qtype = key_type})
  val_vec = lVector( {gen = lgens.val, has_nulls = false, qtype = val_type})
  return key_vec, val_vec
end
-- return mdb -- FOR UNIT TESTING
return require('Q/q_export').export('mk_comp_key_val', mk_comp_key_val)
