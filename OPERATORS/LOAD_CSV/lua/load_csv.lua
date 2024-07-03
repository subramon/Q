-- This version supports chunking in load_csv
local ffi           = require 'ffi'
local cutils        = require 'libcutils'
local lgutils       = require 'liblgutils'
local lVector       = require 'Q/RUNTIME/VCTR/lua/lVector'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/validate_meta"
local process_opt_args = 
  require "Q/OPERATORS/LOAD_CSV/lua/process_opt_args"
local malloc_buffers_for_data = 
  require "Q/OPERATORS/LOAD_CSV/lua/malloc_buffers_for_data"
local data_buffers_for_C = 
  require "Q/OPERATORS/LOAD_CSV/lua/data_buffers_for_C"
local malloc_aux    = require "Q/OPERATORS/LOAD_CSV/lua/malloc_aux"
local aux_for_C     = require "Q/OPERATORS/LOAD_CSV/lua/aux_for_C"
local bridge_C      = require "Q/OPERATORS/LOAD_CSV/lua/bridge_C"
local get_ptr       = require 'Q/UTILS/lua/get_ptr'

 --======================================
local function load_csv(
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  opt_args
  )
  assert( type(infile) == "string")
  assert(cutils.isfile(infile))
  assert(tonumber(cutils.getsize(infile)) > 0)

  local is_hdr, is_par,fld_sep, global_memo_len, max_num_in_chunk, 
    nn_qtype = process_opt_args(opt_args)
  local c_nn_qtype = cutils.get_c_qtype(nn_qtype)
  assert(validate_meta(M))
  -- if memo_len not provided for field, use global over-ride
  for k, v in pairs(M) do 
    if ( v.memo_len ) then 
      assert(type(v.memo_len) == "number" )
    else
      v.memo_len = global_memo_len
    end
    -- same nn_qtype for all vectors 
    if ( v.has_nulls ) then 
      v.nn_qtype = nn_qtype
    end 
  end
  --=======================================

  local l_file_offset, l_num_rows_read, l_is_load, l_has_nulls, 
    l_is_trim, l_width, l_c_qtypes = 
    malloc_aux(M)
  local file_offset, num_rows_read, is_load, has_nulls, 
    is_trim, width, c_qtypes = 
    aux_for_C(M, l_file_offset, l_num_rows_read, l_is_load, l_has_nulls, 
    l_is_trim, l_width, l_c_qtypes)
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
        l_file_offset:nop()
        l_num_rows_read:nop()
        l_is_load:nop()
        l_has_nulls:nop()
        l_is_trim:nop()
        l_width:nop()
        l_c_qtypes:nop()
        -- Allocate buffers for each loadable column 
        local l_data, nn_l_data = 
          malloc_buffers_for_data(M, max_num_in_chunk)
        --=== Set up pointers to the data buffers for each loadable column
        local c_data, nn_c_data = data_buffers_for_C(M, l_data, nn_l_data)
        local x_data = get_ptr(c_data, "char **")
        local nn_x_data = get_ptr(nn_c_data, "char **")

        for k, v in ipairs(M) do
          if ( v.is_load ) then 
            l_data[v.name]:nop()
            if ( v.has_nulls ) then
              nn_l_data[v.name]:nop()
            end
          end
        end
        -- print("chunk_num/mem_used = ", chunk_num, lgutils.mem_used())
        --===================================
        assert(chunk_num == l_chunk_num)
        l_chunk_num = l_chunk_num + 1 
        --===================================
        local x = bridge_C(M, infile, fld_sep, is_hdr, is_par, 
          max_num_in_chunk, file_offset, num_rows_read, x_data, nn_x_data,
          is_load, has_nulls, is_trim, width, c_qtypes, c_nn_qtype)
        assert(x == true)
        local this_num_rows_read = tonumber(num_rows_read[0])
        -- following not necesssary. Old C programmer's habit
        c_data:delete(); nn_c_data:delete()
        --===================================
        if ( this_num_rows_read > 0 ) then 
          for _, v in ipairs(M) do 
            if ( ( v.name ~= my_name )  and ( v.is_load ) ) then
              -- print("putting chunk for " .. v.name)
              vectors[v.name]:put_chunk(
                l_data[v.name], this_num_rows_read, nn_l_data[v.name])
              -- print("put chunk for " .. v.name)
            end
          end
        end 
        -- print("put all chunks")
        --=====================
        if ( this_num_rows_read == 0 ) then 
          for k, v in ipairs(M) do
            if ( v.is_load ) then 
              l_data[v.name]:delete()
              if ( v.has_nulls ) then
                nn_l_data[v.name]:delete()
              end
            end
          end
        end
        --=====================
        if ( this_num_rows_read < max_num_in_chunk ) then 
          -- signal eov for all vectors other than yourself
          for _, v in ipairs(M) do 
            if ( ( v.name ~= my_name )  and ( v.is_load ) ) then
              vectors[v.name]:eov()
            end
          end
          -- you can delete your local buffers
          l_file_offset:delete()
          l_num_rows_read:delete()
          l_is_load:delete()
          l_has_nulls:delete()
          l_is_trim:delete()
          l_width:delete()
          l_c_qtypes:delete()
        end
        -- print("returning " ..  this_num_rows_read)
        return this_num_rows_read, l_data[v.name], nn_l_data[v.name]
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
      tinfo.name      = v.name
      tinfo.gen       = lgens[v.name]
      tinfo.has_nulls = v.has_nulls
      if ( tinfo.has_nulls ) then 
        tinfo.nn_qtype  = nn_qtype
      end 
      tinfo.qtype     = v.qtype
      tinfo.max_num_in_chunk  = max_num_in_chunk
      if ( tinfo.qtype == "SC" ) then tinfo.width = v.width end 
      local V = lVector(tinfo)
      V:set_name(v.name)
      if ( v.meaning ) then 
        V:set_meta("_meta.meaning", M[i].meaning)
      end
      -- print("max_num_in_chunk for " .. v.name .. " is " ..  v.max_num_in_chunk)
      V:memo(v.memo_len)
      vectors[v.name] = V
    end
  end
  -- Note that while M is a table indexed as 1, 2, ...
  -- the table of Vectors that we return is indexed with field names
  return vectors
end
return require('Q/q_export').export('load_csv', load_csv)
