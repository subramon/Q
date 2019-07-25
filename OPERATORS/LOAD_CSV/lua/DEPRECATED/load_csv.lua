local data_dir      = require('Q/q_export').Q_DATA_DIR
local Dictionary    = require 'Q/UTILS/lua/dictionary'
local err           = require 'Q/UTILS/lua/error_code'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local lVector       = require 'Q/RUNTIME/lua/lVector'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/validate_meta"
local is_accelerate = require "Q/OPERATORS/LOAD_CSV/lua/is_accelerate"
local process_opt_args = require "Q/OPERATORS/LOAD_CSV/lua/process_opt_args"
local init_buffers  = require "Q/OPERATORS/LOAD_CSV/lua/init_buffers"
local load_csv_fast_C  = require "Q/OPERATORS/LOAD_CSV/lua/load_csv_fast_C"
local update_out_buf   = require "Q/OPERATORS/LOAD_CSV/lua/update_out_buf"
local flush_bufs    = require "Q/OPERATORS/LOAD_CSV/lua/flush_bufs"
local get_ptr	    = require 'Q/UTILS/lua/get_ptr'
local cmem          = require 'libcmem'
local hash          = require 'Q/OPERATORS/HASH/lua/hash'
 --======================================
local function load_csv(
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  opt_args
  )
  assert( infile ~= nil and qc["file_exists"](infile),err.INPUT_FILE_NOT_FOUND)
  assert(tonumber(qc["get_file_size"](infile)) > 0, err.INPUT_FILE_EMPTY)

  validate_meta(M) -- Validate Metadata
  local use_accelerator, is_hdr = process_opt_args(opt_args)
  
  local cols_to_return -- this is what we return 

  -- use optimized C code if okay to do so 
  local l_is_accelerate = is_accelerate(M) 
  if ( l_is_accelerate and use_accelerator )then
    local tt  = load_csv_fast_C(M, infile, is_hdr)
    -- START: Change indexes from 1, 2, 3 to names of columns
    local ttidx = 1
    local cols_to_return = {}
    for i = 1, #M do 
      if ( M[i].is_load ) then 
        cols_to_return[M[i].name] = tt[ttidx]
        ttidx = ttidx + 1
      end
      if ( M[i].meaning ~= nil ) then 
        assert(type(M[i].meaning) == "string", "type of meaning field is not string")
        cols_to_return[M[i].name]:set_meta("meaning", M[i].meaning)
      end
    end
    return cols_to_return
  end
  -- Initialize Buffers
  local cols, dicts, out_bufs, nn_out_bufs, n_buf = init_buffers(M)

  -- Memory map the input file
  -- TODO: review below code with Ramesh
  local mmaped_file = ffi.gc(ffi.C.malloc(ffi.sizeof("char *")), ffi.C.free)
  --local mmaped_file = cmem.new(ffi.sizeof("char *"), "F4", "file")
  mmaped_file = ffi.cast("char **", mmaped_file)
  local file_size = ffi.gc(ffi.C.malloc(ffi.sizeof("size_t")), ffi.C.free)
  --local file_size = cmem.new(ffi.sizeof("size_t"), "F4", "size")
  file_size = ffi.cast("size_t *", file_size)

  local status = qc.rs_mmap(infile, mmaped_file, file_size, false)
  assert(status == 0, err.MMAP_FAILED)

  local X = mmaped_file[0]
  local nX = tonumber(file_size[0])
  assert(nX > 0, err.FILE_EMPTY)
  --===================================================
  
  local x_idx = 0
  local sz_in_buf = 2048 -- TODO Undo hard coding 
  local in_buf  = assert(cmem.new(sz_in_buf))
  local in_buf_ptr  = ffi.cast("char *", get_ptr(in_buf))
  -- in_lbuf is required for get_cell to perform the trim operation
  local in_lbuf = assert(cmem.new(sz_in_buf))
  local in_lbuf_ptr  = ffi.cast("char *", get_ptr(in_lbuf))
  local row_idx = 1
  local col_idx = 1
  local num_in_out_buf = 0
  local num_cols = #M
  local consumed_hdr = false
  local num_cells_consumed = 0

  while true do
    local is_last_col = false
    if ( col_idx == num_cols ) then
      is_last_col = true;
    end
    if M[col_idx].qtype == "SV" or M[col_idx].qtype == "SC" then
      -- Here, we don't want to perform trim operation in get_cell
      x_idx = qc.get_cell(X, nX, x_idx, is_last_col, in_buf_ptr, nil, sz_in_buf)
    else
      x_idx = qc.get_cell(X, nX, x_idx, is_last_col, in_buf_ptr, in_lbuf_ptr, sz_in_buf)
    end
    x_idx = tonumber(x_idx)
    assert(x_idx > 0 , err.INVALID_INDEX_ERROR)
    if ( ( not is_hdr ) or ( is_hdr and consumed_hdr ) ) then 
      assert(x_idx > 0 , err.INVALID_INDEX_ERROR)
      if ( M[col_idx].is_load ) then
        local str = ffi.string(in_buf_ptr)
        local is_null = (str == "")
        -- Process null value case
        if is_null then
          assert(M[col_idx].has_nulls, err.NULL_IN_NOT_NULL_FIELD)
          M[col_idx].num_nulls = M[col_idx].num_nulls + 1
        else
          if M[col_idx].has_nulls then
            -- Update nn_out_buf
            local temp_nn_out_buf = ffi.cast(qconsts.qtypes.B1.ctype .. " *", get_ptr(nn_out_bufs[col_idx]))
            qc.set_bit_u64(temp_nn_out_buf, num_in_out_buf, 1)
          end
          update_out_buf(in_buf_ptr, M[col_idx], dicts[col_idx],
          get_ptr(out_bufs[col_idx]), num_in_out_buf, n_buf)
        end
      end
      --=======================================
    else
      -- print("Ignore this line since its header line")
    end
    col_idx = col_idx + 1
    if ( is_last_col ) then
      col_idx = 1;
      if ( ( not is_hdr) or ( is_hdr and consumed_hdr ) ) then 
        row_idx = row_idx + 1
        num_in_out_buf = num_in_out_buf + 1
        if ( num_in_out_buf == n_buf ) then
          flush_bufs(cols, M, out_bufs, nn_out_bufs, num_in_out_buf)
          num_in_out_buf = 0
        end
      end
      if ( is_hdr and ( not consumed_hdr ) ) then 
        consumed_hdr = true
      end
    end
    assert(x_idx <= nX)
     if  (x_idx >= nX) then break end
    num_cells_consumed = num_cells_consumed + 1
  end
  assert(x_idx == nX, err.DID_NOT_END_PROPERLY)
  assert(col_idx == 1, err.BAD_NUMBER_COLUMNS)

  if ( num_in_out_buf > 0 ) then
    flush_bufs(cols, M, out_bufs, nn_out_bufs, num_in_out_buf)
  end
  --======================================
  --print("Preparing return columns")
  cols_to_return = {}
  for i = 1, #M do
    if ( M[i].is_load ) then
      cols[i]:eov()
      if ( ( M[i].has_nulls ) and ( M[i].num_nulls == 0 ) ) then
        -- Drop the null column, get the nn_file_name from metadata
        local null_file = cols[i]:meta().nn.file_name
        cols[i]:drop_nulls()
        -- assert(qc["delete_file"](null_file),err.INPUT_FILE_NOT_FOUND)
      end
      cols[i]:set_meta("num_nulls", M[i].num_nulls)
      cols_to_return[M[i].name] = cols[i]
      if M[i].qtype == "SC" and M[i].convert_sc and M[i].convert_sc == true then
        local hash_col_for_sc = hash(cols[i])
        hash_col_for_sc:eov()
        hash_col_for_sc:set_meta("has_nulls", cols[i]:get_meta('has_nulls'))
        hash_col_for_sc:set_meta("num_nulls", cols[i]:get_meta('num_nulls'))
        cols_to_return[M[i].name .. "_I8"] = hash_col_for_sc
      else
        -- convert_sc field is set to false, not converting 'SC' to 'hash'
      end
    end
  end

  X = ffi.cast("char *", X)
  status = qc.rs_munmap(X, nX)
  assert(status == 0, "Unmap failed")
  return cols_to_return
end

return require('Q/q_export').export('load_csv', load_csv)
