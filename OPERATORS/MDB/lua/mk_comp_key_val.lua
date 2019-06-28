-- Inputs are 
-- (a) a table of keys 
-- (2) val_vec, a vector representing value being aggregated
-- (Note that we currently do NOT support aggregation of multiple values
-- Output is 
-- (1) a Vector representing the composite key
-- (2) a Vector representing the value (obtained from Vin)
local function mk_comp_key_val(Tk, val_vec)
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
  for i = 1, nD do 
    assert(type(in_vecs[i] == "lVector"))
  end
  -- currently only one value can be aggregated
  assert(type(val_vec) == "lVector") 
  local val_type = val_vec:fldtype()
  assert ( ( val_type == "I1" ) or ( val_type == "I2" ) or ( val_type == "I4" ) or 
           ( val_type == "I8" ) or ( val_type == "F4" ) or ( val_type == "F8" ) )
  assert(type(Tk) == "table")
  local template, nR, nD, nC = mk_template(nDR)
  --===================================================================
  -- START: Specialization
  local spfn = require("Q/OPERATORS/MDB/lua/mk_comp_key_val_specialize" )
  local status, subs, tmpl = pcall(spfn, val_type)
  assert(status, "error: mk_comp_key_val_specialize()")
  assert(type(subs) == "table", "error: mk_comp_key_valsort_specialize()")
  local func_name = assert(subs.fn)
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
    float *in_measure_val, /* [nV] */
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
  local key_type = "I8" -- HARD CODED
  local key_cast_as = "uint64_t * " -- HARD CODED
  local key_width = qconsts.qtypes[key_type].width
  local key_buf = assert(ffi.cast(key_cast_as,
          get_ptr(cmem.new(nK * key_width, key_type))))

  local val_ctype = qconsts.qtypes[val_type].ctype
  local val_cast_as = val_ctype .. " * "
  local val_width = qconsts.qtypes[val_type].width
  local val_buf = assert(ffi.cast(val_cast_as, 
          get_ptr(cmem.new(nK * val_width, val_type))))

  local nK = qconsts.chunk_size
  --==============================================
  local in_dim_vals = ffi.cast("uint8_t **",
    get_ptr(cmem.new(nD * ffi.sizeof("uint8_t *"))))
  --==============================================
  -- Unlike usual pattern, we are pre-allocating buffers
  -- Usually, we wait for first call to do so 
  local chunk_idx = 0
  --===================================================================
  local M = { "key", "val" }
  lgens = {} -- we make a table of two generators 
  for _, vecname in pairs(M) do 
    local function kv_gen(chunk_num)
      assert(chunk_num == chunk_idx)
      local len   = {}
      local chunk = {}
      if ( 0 ) then -- you need to consume more stuff ) then 
        for i = 1, nD do 
          len[i], chunk[i] = in_vecs[i]:chunk(chunk_idx)
        end
      end
      -- Check that all input vectors behave similarly
      for i = 2, nD do 
        assert(len[i] == len[1] )
        if ( chunk[1] == nil ) then assert(chunk[i] == nil) end 
        if ( chunk[1] ~= nil ) then assert(chunk[i] ~= nil) end 
      end
      --==============================
      if ( len[1] == 0 ) then 
        if ( vecname == "key" ) then 
          key_vec:eov()
        elseif ( vecname == "val" ) then 
          val_vec:eov()
        end
        return 0, nil
      end
      --==============
      -- Cast input the way C needs it 
      for i = 1, nD do 
        in_dim_vals[i-1] = ffi.cast("uint8_t *", get_ptr(chunk[i]))
      end
      -- TODO Need to adjust nV
      local nV = qconsts.chunk_size
      local start_time = qc.RDTSC()
      local status = fnptr(template, nR, nC, in_dim_vals, in_measure_val, 
       key_buf, val_buf, nV, nK)
      assert(status == 0)
      record_time(start_time, func_name)
      -- here's a bit of trickery needed to handle the case that the 
      -- vectors are produced at the same time and are not independent
      if ( vecname == "key" ) then 
        val_vec:put_chunk(val, nil, num_kvs_produced)
        return num_kvs_produced, key_buf
      elseif ( vecname == "val" ) then 
        key_vec:put_chunk(val, nil, num_kvs_produced)
        return num_kvs_produced, val_buf
      end
      --===========================
    end
    lgens[vecname] = kvgen
  end
  key_vec = lVector( {gen = gens.key, has_nulls = false, qtype = key_type})
  val_vec = lVector( {gen = gens.val, has_nulls = false, qtype = val_type})
  return key_vec, val_vec
end
-- return mdb -- FOR UNIT TESTING
return require('Q/q_export').export('mk_comp_key_val', mk_comp_key_val)
