-- This version supports chunking in load_csv
local ffi           = require 'ffi'
local cutils        = require 'libcutils'
local lVector       = require 'Q/RUNTIME/VCTRS/lua/lVector'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/validate_meta"
local process_opt_args = 
  require "Q/OPERATORS/LOAD_CSV/lua/process_opt_args"
local malloc_buffers_for_data = 
  require "Q/OPERATORS/LOAD_CSV/lua/malloc_buffers_for_data"
local malloc_aux    = require "Q/OPERATORS/LOAD_CSV/lua/malloc_aux"
local bridge_C      = require "Q/OPERATORS/LOAD_CSV/lua/bridge_C"
local qcfg          = require 'Q/UTILS/lua/qcfg'
local setup_ptrs    = require 'Q/OPERATORS/LOAD_CSV/lua/setup_ptrs'
local free_buffers    = require 'Q/OPERATORS/LOAD_CSV/lua/free_buffers'

local max_num_in_chunk = qcfg.max_num_in_chunk
 --======================================
local function load_csv(
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  opt_args
  )
  local max_num_in_chunk = max_num_in_chunk
  assert( type(infile) == "string")
  assert(cutils.isfile(infile))
  assert(tonumber(cutils.getsize(infile)) > 0)

  assert(validate_meta(M))
  local is_hdr, fld_sep, global_memo_len = process_opt_args(opt_args)
  -- see if you need to over ride per field memo_len with global
  if ( type(global_memo_len) == "number" ) then
    for k, v in pairs(M) do 
      v.memo_len = global_memo_len
    end
  end
  --=======================================

  local file_offset, num_rows_read, is_load, has_nulls, is_trim, width, 
    c_qtypes = malloc_aux(#M)
  --=======================================
  local vectors = {} 

  local l_chunk_num = 0
  -- This is tricky. We create generators for each vector
  local lgens = {}
  for midx, v in ipairs(M) do 
    local my_name = v.name
    if ( v.is_load ) then 
      local name = v.name
      local function lgen(chunk_num)
        --=== Set up pointers to the data buffers for each loadable column
        local databuf, nn_databuf = malloc_buffers_for_data(M)
        local cdata = ffi.new("char *[?]", #M)
        local nn_cdata = ffi.new("uint64_t *[?]", #M)
        setup_ptrs( M, databuf, nn_databuf, cdata, nn_cdata)
        --===================================
        assert(chunk_num == l_chunk_num)
        l_chunk_num = l_chunk_num + 1 
        --===================================
        assert(bridge_C(M, infile, fld_sep, is_hdr, max_num_in_chunk,
          file_offset, num_rows_read, cdata, nn_cdata,
          is_load, has_nulls, is_trim, width, c_qtypes))
        local l_num_rows_read = tonumber(num_rows_read[0])
        --===================================
        if ( l_num_rows_read > 0 ) then 
          for _, v in ipairs(M) do 
            if ( ( v.name ~= my_name )  and ( v.is_load ) ) then
              vectors[v.name]:put_chunk(
                databuf[v.name], l_num_rows_read, nn_databuf[v.name])
            end
          end
        end 
        --=====================
        if ( l_num_rows_read < max_num_in_chunk ) then 
          -- signal eov for all vectors other than yourself
          for _, v in ipairs(M) do 
            if ( ( v.name ~= my_name )  and ( v.is_load ) ) then
              vectors[v.name]:eov()
            end
          end
        end
        return l_num_rows_read, databuf[v.name], nn_databuf[v.name]
      end
      lgens[my_name] = lgen
    end
  end
  -- Note that you *may* have a vector that does not have any null 
  -- vales but still has a nn_vec. This will happen if you marked it as
  -- has_nulls==true. Caller's responsibility to clean this up
  --==============================================
  for _, v in ipairs(M) do 
    if ( v.is_load ) then 
      local tinfo = {}
      tinfo.gen       = lgens[v.name]
      tinfo.has_nulls = v.has_nulls
      tinfo.qtype     = v.qtype
      if ( tinfo.qtype == "SC" ) then tinfo.width = v.width end 
      local V = lVector(tinfo)
      V:set_name(v.name)
      if ( v.meaning ) then 
        V:set_meta("_meta.meaning", M[i].meaning)
      end
      V:memo(v.memo_len)
      vectors[v.name] = V
    end
  end
  -- Note that while M is a table indexed as 1, 2, ...
  -- the table of Vectors that we return is indexed with field names
  return vectors
end
return require('Q/q_export').export('load_csv', load_csv)
