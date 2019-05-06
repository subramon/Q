local qconsts = require 'Q/UTILS/lua/q_consts'
local err = require 'Q/UTILS/lua/error_code'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/validate_meta"
local Dictionary = require 'Q/OPERATORS/DATA_LOAD/lua/dictionary_dataload'
local plstring = require 'pl.stringx'
local lVector = require 'Q/RUNTIME/lua/lVector'
local plpath = require 'pl.path'
local pllist = require 'pl.List'
local plfile = require 'pl.file'
local qc = require 'Q/UTILS/lua/q_core'
local ffi = require 'Q/UTILS/lua/q_ffi'
-- ----------------
-- load( "CSV file to load", "meta data", "Global Metadata")
-- Loads the CSV file and stores in the Q internal format
--
-- returns : table containing list of files for each column defined in metadata.
--           If any error was encountered during load operation then negative status code
-- ----------------

return function ( 
  csv_file_path, 
  M,  -- metadata
  load_global_settings
  )
  local column_list = {}
  local dict_table = {}
  local col_num_nil = {}
  local size_of_data_list = {}
   
  -- assert(type(_G["Q_DICTIONARIES"]) == "table",err.NULL_DICTIONARY_ERROR)
   
  assert( csv_file_path ~= nil and plpath.isfile(csv_file_path),err.INPUT_FILE_NOT_FOUND)
  assert( plpath.getsize(csv_file_path) ~= 0,err.INPUT_FILE_EMPTY)
  -- assert( _G["Q_DATA_DIR"] ~= nil and plpath.isdir(_G["Q_DATA_DIR"]), err.Q_DATA_DIR_NOT_FOUND)
  -- assert( _G["Q_META_DATA_DIR"] ~= nil and plpath.isdir(_G["Q_META_DATA_DIR"]), err.Q_META_DATA_DIR_NOT_FOUND)
  validate_meta(M)
   

  for i = 1, #M do
    M[i].num_nulls = 0
    --default to true
    if M[i].is_load == nil then 
      M[i].is_load = true
    end
      
    if M[i].is_load == true then
      local fld_width = nil
      if M[i].qtype == "SC" then
        fld_width = M[i].width
        size_of_data_list[i] = M[i].width
      else
        size_of_data_list[i] = qconsts.qtypes[M[i].qtype]["width"]
      end
      
      -- If user does no specify null value, then treat null = true as default
      if M[i].has_nulls == nil or M[i].has_nulls == "" then
        M[i].has_nulls = true
      end
    
      column_list[i] = lVector{qtype=M[i].qtype, 
                 gen = true,
                 width=fld_width,
                 is_memo = true,
                 has_nulls = M[i].has_nulls,}
      col_num_nil[i] = nil
                 
      if M[i].qtype == "SV" then
        -- initialization to {} is required, if not done then in the second statement dict_table[i].dict, dict_table[i] will be nil
        dict_table[i] = {}
        dict_table[i].dict = assert(Dictionary(M[i]), err.ERROR_CREATING_ACCESSING_DICT )
        dict_table[i].add_new_value = M.add
        column_list[i]:set_meta("dir",dict_table[i].dict)
      end 
    end    
  end
   
   -- mmap function here
   local f_map = ffi.gc(qc.f_mmap(csv_file_path, false), qc.f_munmap)
   assert(f_map.status == 0 , "Mmap failed")
   local X = ffi.cast("char *", f_map.map_addr)
   local nX = tonumber(f_map.map_len)
   assert(nX > 0, "File cannot be empty")
   
   local x_idx = 0
   
   -- Take the max value from all the types
   -- pllist is a penlight list class, here used to find maximum values among the list of values 
   -- https://stevedonovan.github.io/Penlight/api/classes/pl.List.html
   local l = pllist()
   for i, value in pairs(qconsts.width) do
    l:append(value) 
   end
   l:append(2*qconsts.max_width.SC)
   local min, cbuf_sz = l:minmax()  -- max value will be cbuff_sz, since c conversion will be to either one of the types contained in g_sz
   
   l:append(2*qconsts.max_width.SV)
   local min, buf_sz = l:minmax() -- buf_sz is the max size of the input indicated by globals
   
   local buf  = assert(ffi.malloc(buf_sz))
   local cbuf = assert(ffi.malloc(cbuf_sz))
   local is_null = assert(ffi.malloc(1))
   local ncols = #M
   local row_idx = 0
   local col_idx = 0
   
   while true do
      local is_last_col
      if col_idx == (ncols-1) then
         is_last_col = true;
      else
         is_last_col = false;
      end
      x_idx = tonumber( qc.get_cell(X, nX, x_idx, is_last_col, buf, buf_sz)  )

      assert(x_idx > 0 , err.INVALID_INDEX_ERROR)
      
      -- check if the column needs to be skipped while loading or not 
      if column_list[col_idx  + 1 ] then 
        ffi.fill(is_null, 1, 255) -- initially will be false = 1
  
        if M[col_idx + 1].qtype == "SV" then 
          if plstring.strip(ffi.string(buf)) ~= "" then 
            local ret_number = dict_table[col_idx + 1].dict:add_with_condition(ffi.string(buf),
              dict_table[col_idx + 1].add_new_value)  
            ffi.copy(buf, tostring(ret_number))
          end   
        elseif M[col_idx + 1].qtype == "SC" then 
          assert( string.len(ffi.string(buf)) <= M[col_idx + 1].width -1, err.STRING_GREATER_THAN_SIZE )  
        end
             
        ffi.fill(cbuf, size_of_data_list[col_idx + 1], 0)
        local str = plstring.strip(ffi.string(buf))
        --if q_core.string(buf) == "" then 
        if str == "" then 
          -- nil values
          assert( M[col_idx + 1].has_nulls == true, err.NULL_IN_NOT_NULL_FIELD )
          M[col_idx + 1].num_nulls = M[col_idx + 1].num_nulls + 1
          ffi.fill(is_null, 1, 0)
          if col_num_nil[col_idx + 1] == nil then 
            col_num_nil[col_idx + 1] =  1 
          else 
            col_num_nil[col_idx + 1] = col_num_nil[col_idx + 1] + 1
          end          
        else 
          local status = nil
          local qtype = M[col_idx + 1].qtype
          local function_name = qconsts.qtypes[qtype]["txt_to_ctype"]
          -- for fixed size string pass the size of string data also
          if qtype == "SC" then
            ffi.copy(cbuf, buf, string.len(ffi.string(buf))) 
            status = 0 
          elseif qtype == "I1" or qtype == "I2" or qtype == "I4" or qtype == "I8" or qtype == "SV" then
            -- For now second parameter , base is 10 only
            -- print(function_name)
            status = qc[function_name](buf, cbuf)
          elseif qtype == "F4" or qtype == "F8"  then 
            status = qc[function_name](buf, cbuf)
          else 
            error("Data type : " .. qtype .. " Not supported ")
          end
          
          assert( status >= 0 , err.INVALID_DATA_ERROR )
        end   
           
        column_list[col_idx+1]:put_chunk(cbuf, is_null, 1)

        if is_last_col then
           row_idx = row_idx + 1
           col_idx = 0;
        else
           col_idx = col_idx + 1 
        end
        
        if x_idx >= nX then 
          break 
        end
      end
   end

   for i, column in pairs(column_list) do
      column:eov()
      print("EOV Done ", i)
      -- print(column:length())
      -- if no nulls are present, then delete the null file
      if ( ( M[i].has_nulls ) and ( M[i].num_nulls == 0 ) ) then
        --local null_file = require('Q/q_export').Q_DATA_DIR .. "/_" .. M[i].name .. "_nn"
        --assert(plfile.delete(null_file),err.INPUT_FILE_NOT_FOUND)
      end
   end
   -- print("Completed successfully")
   return column_list
end
