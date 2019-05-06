require 'Q/UTILS/lua/globals'

-- table for random functions
local random_func = {}

local fns = {} 
--to convert row (table) into comma separated line
local to_csv = function  (tt)
  local s = ""
  for _,p in ipairs(tt) do 
    s = s .. "," .. p
  end
    return(string.sub(s, 2))    
end

--placing random seed once at start for generating random no. each time
math.randomseed(os.time())

random_func.random_int8_t = function ()
  return math.random(1,127)
end

random_func.random_int16_t = function ()
  return math.random(1,32767)
end

random_func.random_int32_t = function ()
  return math.random(1,2147483647)
end

random_func.random_float = function ()
  return math.random(100000,900000) / 10
end

local charset = {}
-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i))  end
for i = 65,  90 do table.insert(charset, string.char(i))  end
for i = 97, 122 do table.insert(charset, string.char(i))  end

random_func.random_SC = function(length_inp)
    local length = length_inp
    if length > 0 then
        return random_func.random_SC(length - 1) .. charset[math.random(1, #charset)]
    end
    return ""
end

random_func.random_SV = function(size)
    random_len = math.random(1,size)
    string = random_func.random_SC(random_len)
    return string
end

--generating maximum specified unique strings
local dict_size_unique_string = function (max_str_size, max_idx)
  local str
  local unique_strings_table = {'""'} --for storing unique strings in table
  local reverse_storing = {'""'} --for searching string in 0(n) time
  local idx = 2

  repeat  
    str = random_func.random_SV(max_str_size-1)
    if(reverse_storing[str] == nil) then 
      --IF generated string is not in the table then insert in both the tables 
      unique_strings_table[idx] = str
      reverse_storing[str] = idx
      idx = idx + 1
    end
  until idx == max_idx + 1
  
  return unique_strings_table
end

--generating unique strings for each varchar column
fns.generate_unique_varchar_strings = function(meta_info)
  local unique_string_tables = {}
  local is_varchar_col = false
  
  for i=1, #meta_info do
    if meta_info[i]['qtype']=='SV' then
      is_varchar_col= true
      
      --calculating possible unique string limit
      local exp_unique_strings= 0
      for j=1, meta_info[i]['max_width']-1 do
        exp_unique_strings = exp_unique_strings + math.pow(#charset, j)
      end
      --print("For string length ",meta_info[i]['width']-1," value is ",exp_unique_strings)
      -- before gen unique strings checking if max_unique_value is within possible limit
      assert(meta_info[i]['max_unique_values'] <= exp_unique_strings,"Specified Unique string limit is beyond possible limit value...")
      unique_string_tables[i] = dict_size_unique_string(meta_info[i]['max_width'],meta_info[i]['max_unique_values'])
    end
  end  
  if is_varchar_col == false then
    return nil 
  end
  return unique_string_tables
end


--generating metadata table(returns metadata table generated)
fns.generate_metadata = function(meta_info)
  
  local metadata_table= {}
  local idx=1
  local col_name= 'col' --for giving names to each column
  
  for i=1, #meta_info do
    for k = 1 , meta_info[i]['column_count'] do
      metadata_table[idx] = {}
      metadata_table[idx]['name'] = col_name ..idx
      metadata_table[idx]['qtype'] = meta_info[i]['qtype']
      metadata_table[idx]['has_nulls'] = meta_info[i]['has_nulls']
      
      if meta_info[i]['qtype']== 'SC' then
        metadata_table[idx]['width'] = meta_info[i]['width']
      elseif meta_info[i]['qtype']== 'SV' then
        metadata_table[idx]['max_width'] = meta_info[i]['max_width']
        metadata_table[idx]['add'] = meta_info[i]['add']
        metadata_table[idx]['dict'] = "D"..i
        metadata_table[idx]['unique_table_id']= i
        metadata_table[idx]['max_unique_values'] = meta_info[i]['max_unique_values']
        if k==1 then
          metadata_table[idx]['is_dict'] = false
        else
          metadata_table[idx]['is_dict'] = true
        end
      end
      idx = idx +1
    end
  end
  --pretty.dump(metadata_table)
  return metadata_table
end


--function to fill the chunk_print_size table with data
local function fill_table(column_list, chunk_print_size,unique_string_tables)
  local file_data = { }
  local col_length = #column_list
  
  for ind=1, chunk_print_size do
    --fill table data
    file_data[ind] = {}
    for j=1, col_length do
      if column_list[j]['qtype']=='SC' then
        local func ='random_'..column_list[j]['qtype']
        local size = column_list[j]['width']-1
        table.insert(file_data[ind],random_func[func](size))
      elseif column_list[j]['qtype']=='SV' then
        local random_no = math.random(1,column_list[j]['max_unique_values'])
        local dict_no = column_list[j]['unique_table_id']
        assert(unique_string_tables~=nil,"Attempting to use unique string table which doesnt exists")
        table.insert(file_data[ind],unique_string_tables[dict_no][random_no])
      else
        local data_type_short_code = column_list[j]['qtype']
        local func ='random_'..g_qtypes[data_type_short_code]['ctype']
        table.insert(file_data[ind],random_func[func]())
      end
    end
  end
  return file_data  
end

--function to write the table data into csv file and then empty the table
local write_and_empty_table = function (chunk_print_size, file_data, file)
  local final_csv_string = ''
  for ind=1, chunk_print_size do
    --write file data and empty table data
    local csv_string = to_csv(file_data[ind])
    final_csv_string = final_csv_string..csv_string.."\n"
    file_data[ind]=nil
  end
   file:write(final_csv_string)
end


--generating csv file based on metadata (this function returns no of rows generated)
fns.generate_csv_file = function(csv_file_name, metadata_table, row_count, chunk_print_size,unique_string_tables)
  local file = assert(io.open(csv_file_name, 'w')) 
  local no_of_chunks = math.floor(row_count/chunk_print_size)
  local chunks = 1
  local table_data = { }
  
  while( chunks <= no_of_chunks) do
    table_data = fill_table(metadata_table, chunk_print_size, unique_string_tables)
    write_and_empty_table(chunk_print_size, table_data, file)
    print("Written "..chunk_print_size*chunks.." rows in "..csv_file_name.." file")
    chunks = chunks + 1
  end
  
  --for the last chunk
  local last_chunk_rows = no_of_chunks*chunk_print_size
  local last_chunk_print_size = 0
  
  if(last_chunk_rows < row_count)then
    last_chunk_print_size = row_count - last_chunk_rows
    table_data = fill_table(metadata_table, last_chunk_print_size, unique_string_tables)
    write_and_empty_table(last_chunk_print_size, table_data, file)
  end
  file:close() --closing csv file
end

return fns