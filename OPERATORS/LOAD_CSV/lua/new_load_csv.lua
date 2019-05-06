-- This version supports chunking in load_csv
local Dictionary    = require 'Q/UTILS/lua/dictionary'
local err           = require 'Q/UTILS/lua/error_code'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local lVector       = require 'Q/RUNTIME/lua/lVector'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/new_validate_meta"
local chk_file      = require "Q/OPERATORS/LOAD_CSV/lua/chk_file"
local process_opt_args = 
  require "Q/OPERATORS/LOAD_CSV/lua/new_process_opt_args"
local malloc_buffers_for_data = 
  require "Q/OPERATORS/LOAD_CSV/lua/malloc_buffers_for_data"
local bridge_C  = require "Q/OPERATORS/LOAD_CSV/lua/bridge_C"
local get_ptr	    = require 'Q/UTILS/lua/get_ptr'
local cmem          = require 'libcmem'
 --======================================
local function load_csv(
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  opt_args
  )
  assert(chk_file(infile))
  assert(validate_meta(M))
  local is_hdr, fld_sep = process_opt_args(opt_args)
  --=======================================
  local file_offset = ffi.cast("uint64_t *", 
    get_ptr(cmem.new(1*ffi.sizeof("uint64_t"))))
  file_offset[0] = 0

  local num_rows_read = ffi.cast("uint64_t *", 
    get_ptr(cmem.new(1*ffi.sizeof("uint64_t"))))

  local fld_sep = M.fld_sep
  assert(malloc_buffers_for_data(M))
  local vectors = {} 
  --=======================================
  -- This is tricky. We create generators for each vector
  lgens = {}
  for midx, v in pairs(M) do 
    lgens[name] = nil
    if ( v.is_load ) then 
      local name = v.name
      local function lgen()
        num_rows_read[0] = 0
        --===================================
        local start_time = qc.RDTSC()
        assert(bridge_C(M, infile, fld_sep, is_hdr,
          file_offset, num_rows_read, data, nn_data))
        record_time(start_time, "load_csv_fast")
        --===================================
        for i = 1, #M do
          if ( i ~= midx ) then 
            vectors[i]:put_chunk(data[i], nn_data[i], num_rows_read)
          end
        end
        if ( num_rows_read < qconsts.chunk_size ) then 
          -- Free buffers since you won't need them again
          for i = 1, #M do 
            if ( i ~= midx ) then 
              -- Note subtlety of above if condition.  You can't delete 
              -- buffer for vector whose chunk you are returning
              if (    data[i] ~= nil ) then    data[i]:delete() end
              if ( nn_data[i] ~= nil ) then nn_data[i]:delete() end
            end
          end
        end 
        return num_rows_read, data[midx], nn_data[midx]
      end
    lgens[name] = lgen
    end
  end
  -- Note that you may have a vector that does not have any null 
  -- vales but still has a nn_vec. This will happen if you marked it as
  -- has_nulls==true. Caller's responsibility to clean this up
  --==============================================
  for midx, col in pairs(M) do
    vectors[col.name] = lVector(
      {gen = lgen, has_nulls = col.has_nulls, qtype = col.qtype})
    if ( type(col.meaning) == "string" ) then 
      vectors[col.name]:set_meta("__meaning", M[i].meaning)
    end
    vectors[col.name]:is_memo(col.is_memo)
  end
  return vectors
end

return require('Q/q_export').export('new_load_csv', new_load_csv)
