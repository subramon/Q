-- This version supports chunking in load_csv
local ffi           = require 'ffi'
local cutils        = require 'libcutils'
local cVector       = require 'libvctr'
local lVector       = require 'Q/RUNTIME/VCTR/lua/lVector'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/validate_meta"
local chk_file      = require "Q/OPERATORS/LOAD_CSV/lua/chk_file"
local get_ptr       = require "Q/UTILS/lua/get_ptr"
local process_opt_args = 
  require "Q/OPERATORS/LOAD_CSV/lua/process_opt_args"
local malloc_buffers_for_data = 
  require "Q/OPERATORS/LOAD_CSV/lua/malloc_buffers_for_data"
local F             = require "Q/OPERATORS/LOAD_CSV/lua/malloc_aux"
local bridge_C      = require "Q/OPERATORS/LOAD_CSV/lua/bridge_C"
local record_time   = require 'Q/UTILS/lua/record_time'

 --======================================
local function setup_ptrs(M, databuf, nn_databuf, cdata, nn_cdata)
  assert(cdata)
  assert(nn_cdata)
  assert(type(databuf)    == "table")
  assert(type(nn_databuf) == "table")
  for k, v in pairs(M) do 
    if ( v.is_load ) then 
      assert(databuf[v.name])
      if ( v.has_nulls) then 
        assert(nn_databuf[v.name])
      end
    end
  end

  local ptr_cdata    = ffi.cast("char     **", get_ptr(   cdata))
  local ptr_nn_cdata = ffi.cast("uint64_t **", get_ptr(nn_cdata))
  assert(ptr_cdata)
  assert(ptr_nn_cdata)
  for i, v in ipairs(M) do
    ptr_nn_cdata[i-1] = ffi.NULL
    ptr_cdata   [i-1] = ffi.NULL
    if ( v.is_load ) then 
      ptr_cdata[i-1]  = get_ptr(databuf[v.name])
      if ( v.has_nulls ) then
        ptr_nn_cdata[i-1] = get_ptr(nn_databuf[v.name])
      end
    end
  end
  return ptr_cdata, ptr_nn_cdata
end
 --======================================
local function free_buffers(M, databuf, nn_databuf, my_name)
  -- print(" Free buffers since you won't need them again")
  for i, v in ipairs(M) do 
    if ( v.name ~= my_name ) then
      -- Note subtlety of above if condition.  You can't delete 
      -- buffer for vector whose chunk you are returning
      if ( v.is_load ) then
        databuf[v.name]:delete() 
        if ( v.has_nulls ) then 
          nn_databuf[v.name]:delete() 
        end
      end
    end
  end
end
 --======================================
local function load_csv(
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  opt_args
  )
  assert(chk_file(infile))
  assert(validate_meta(M))
  local is_hdr, fld_sep = process_opt_args(opt_args)
  local chunk_size = cVector.chunk_size()
  --=======================================
  local databuf, nn_databuf, cdata, nn_cdata = malloc_buffers_for_data(M)

  local file_offset, num_rows_read, is_load, has_nulls, is_trim, width, 
    fldtypes = F.malloc_aux(#M)
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
        local ptr_cdata, ptr_nn_cdata = setup_ptrs(
          M, databuf, nn_databuf, cdata, nn_cdata)
        --===================================
        assert(chunk_num == l_chunk_num)
        l_chunk_num = l_chunk_num + 1 
        --===================================
        local start_time = cutils.rdtsc()
        assert(bridge_C(M, infile, fld_sep, is_hdr, chunk_size,
          file_offset, num_rows_read, ptr_cdata, ptr_nn_cdata,
          is_load, has_nulls, is_trim, width, fldtypes))
        record_time(start_time, "load_csv_fast")
        local l_num_rows_read = tonumber(num_rows_read[0])
        --===================================
        if ( l_num_rows_read > 0 ) then 
          for _, v in ipairs(M) do 
            if ( ( v.name ~= my_name )  and ( v.is_load ) ) then
              vectors[v.name]:put_chunk(
                databuf[v.name], nn_databuf[i], l_num_rows_read)
              if ( l_num_rows_read < chunk_size ) then 
                free_buffers(M, databuf, nn_databuf, my_name)
                -- signal eov for all vectors other than yourself
                vectors[v.name]:eov()
              end
            end
          end
        end 
        --=====================
        if ( l_num_rows_read < chunk_size ) then 
          F.free_aux()
        end
        if ( l_num_rows_read > 0 ) then 
          return l_num_rows_read, databuf[v.name], nn_databuf[v.name]
        else
          -- signal eov for all vectors other than yourself
          for _, v in ipairs(M) do 
            if ( ( v.name ~= my_name )  and ( v.is_load ) ) then
              vectors[v.name]:eov()
            end
          end
          return 0, nil, nil
        end
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
        V:set_meta("__meaning", M[i].meaning)
      end
      V:memo(v.is_memo)
      vectors[v.name] = V
    end
  end
  -- Note that while M is a table indexed as 1, 2, ...
  -- the table of Vectors that we return is indexed with field names
  return vectors
end
return require('Q/q_export').export('load_csv', load_csv)
