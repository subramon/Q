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
local F             = require "Q/OPERATORS/LOAD_CSV/lua/malloc_aux"
local bridge_C      = require "Q/OPERATORS/LOAD_CSV/lua/bridge_C"
local get_ptr	    = require 'Q/UTILS/lua/get_ptr'
local cmem          = require 'libcmem'
local record_time   = require 'Q/UTILS/lua/record_time'
 --======================================
local function new_load_csv(
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  opt_args
  )
  assert(chk_file(infile))
  assert(validate_meta(M))
  local is_hdr, fld_sep = process_opt_args(opt_args)
  --=======================================
  local databuf, nn_databuf, cdata, nn_cdata = malloc_buffers_for_data(M)
  local bak_cdata = {}
  for i = 1, #M do 
    bak_cdata[i] = cdata[i-1]
  end
  local file_offset, num_rows_read, is_load, has_nulls, is_trim, width, 
    fldtypes = F.malloc_aux(#M)
  --=======================================
  local vectors = {} 
  local chunk_idx = -1
  -- This is tricky. We create generators for each vector
  local lgens = {}
  for midx, v in pairs(M) do 
    local vec_name = v.name
    if ( v.is_load ) then 
      local name = v.name
      local function lgen(chunk_num)
        for i = 1, #M do 
          cdata[i-1] = bak_cdata[i] -- TODO UNDO 
        end
        chunk_idx = chunk_idx + 1 
        assert(chunk_num == chunk_idx)
        --===================================
        local start_time = qc.RDTSC()
        -- print("BEFORE LUA", cdata, nn_cdata, cdata[0], nn_cdata[0])

        assert(bridge_C(M, infile, fld_sep, is_hdr,
          file_offset, num_rows_read, cdata, nn_cdata,
          is_load, has_nulls, is_trim, width, fldtypes))

        -- print("AFTER  LUA", cdata, nn_cdata, cdata[0], nn_cdata[0])

        record_time(start_time, "load_csv_fast")
        local l_num_rows_read = tonumber(num_rows_read[0])
        --===================================
        if ( l_num_rows_read > 0 ) then 
          for k, v in pairs(M) do 
            if ( ( v.name ~= vec_name )  and ( v.is_load ) ) then
              vectors[v.name]:put_chunk(
                databuf[v.name], nn_databuf[i], l_num_rows_read)
            end
          end
        end
        if ( l_num_rows_read < qconsts.chunk_size ) then 
          -- print(" Free buffers since you won't need them again")
          for k, v in pairs(M) do 
            if ( ( v.name ~= vec_name )  and ( v.is_load ) ) then
              -- Note subtlety of above if condition.  You can't delete 
              -- buffer for vector whose chunk you are returning
              if ( not    databuf[v.name] ) then    
                databuf[v.name]:delete() 
                if ( not nn_databuf[v.name] ) then 
                  nn_databuf[v.namei]:delete() 
                end
              end
              vectors[v.name]:eov()
            end
          end
          F.free_aux()
        end 
        if ( l_num_rows_read > 0 ) then 
          --[[
          print("About to return to lVector for " .. v.name)
          print("base", get_ptr(databuf[v.name]))
          print("base", cdata[0])
          print("nn  ", get_ptr(nn_databuf[v.name]))
          print("nn", nn_cdata[0])
          print("-----------")
          --]]
          return l_num_rows_read, databuf[v.name], nn_databuf[v.name]
        else
          return 0, nil, nil
        end
      end
      lgens[vec_name] = lgen
    end
  end
  -- Note that you may have a vector that does not have any null 
  -- vales but still has a nn_vec. This will happen if you marked it as
  -- has_nulls==true. Caller's responsibility to clean this up
  --==============================================
  for k, v in pairs(M) do 
    if ( v.is_load ) then 
      local tinfo = {}
      tinfo.gen = lgens[v.name]
      tinfo.has_nulls = v.has_nulls
      tinfo.qtype = v.qtype
      if ( tinfo.qtype == "SC" ) then tinfo.width = v.width end 
      vectors[v.name] = lVector(tinfo):set_name(v.name)
      if ( type(v.meaning) == "string" ) then 
        vectors[v.name]:set_meta("__meaning", M[i].meaning)
      end
      vectors[v.name]:memo(v.is_memo)
    end
  end
  return vectors
end

return require('Q/q_export').export('new_load_csv', new_load_csv)
