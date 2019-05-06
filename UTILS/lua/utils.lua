local g_err	= require 'Q/UTILS/lua/error_code'
local base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local qconsts = require 'Q/UTILS/lua/q_consts'

local fns = {}

fns.clone = function(t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

fns.load_file_as_string = function (fname)
  local f = assert(io.open(fname))
  local str = f:read("*a")
  f:close()
  return str
end
-- Following code was taken from : http://lua-users.org/wiki/CsvUtils
-- Used to escape "'s , so that string can be inserted in csv line
fns.escape_csv = function (s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end

fns.preprocess_bool_values = function (metadata_table, ...)
  local col_names = {...}
  for i, metadata in pairs(metadata_table) do 
    for j, col_name in pairs(col_names) do
       if metadata[col_name] ~= nil and type(metadata[col_name]) ~= "boolean" then
        if string.lower(metadata[col_name]) == "true" then
          metadata[col_name] = true
        elseif string.lower(metadata[col_name]) == "false" then
          metadata[col_name] = false
        else
          assert(string.lower(metadata[col_name]) == "true" or string.lower(metadata[col_name]) == "false","Invalid value in metadata for boolean field " .. col_name)
        end
       end
    end
  end
end

--[[ Following contains one liner example of useful tasks, which should be used directly 

- trim the string : stringx.strip(string_data)

- create lua table from string :  table =  pretty.read(table_in_string) 
- dump whole content of table for debugging : pretty.dump(table) 

- check file size : path.getsize(filepath) 

-- ]]

-- function to get table length
fns.table_length= function(tbl)

  local count = 0
  for i in pairs(tbl) do 
    count = count + 1 
  end
  return count 

end

-- function to sort 'string indexed' table into 'integer index' table in a given sort_order 
-- cols  : table of columns with string index
-- order : table of strings (name of string index)
fns.sort_table = function(cols, sort_order)
  assert(type(cols), "cols must be of type table")
  assert(type(sort_order), g_err.INVALID_SORT_ORDER_TYPE)
  -- sort_order table length cannot be 0
  assert(#sort_order > 0, g_err.SORT_ORDER_LENGTH_ZERO )
  -- cols length must be >= sort_order 
  assert(fns.table_length(cols) >= #sort_order, g_err.SORT_ORDER_LENGTH_GT_COLS)

  local sorted_cols = {}
  for i,v in pairs(sort_order) do
    -- order table string name should match cols table string index 
    -- assert(type(v) == "string", "sort_order table value is not of type string") 
    assert(cols[v]~= nil, g_err.INCORRECT_COLUMN_NAME_IN_SORT_ORDER)
    sorted_cols[#sorted_cols + 1] = cols[v]
  end
  
  return sorted_cols
  
end

-- function to get index of a value from a vector
fns.get_index = function(vec, value)
  local val, nn_val
  for i = 0, vec:length() - 1 do
    val, nn_val = vec:get_one(i)
    if val:to_num() == value then
      return i
    end
  end
end

-- function to get vector from table of values
fns.table_to_vector = function(tbl, qtype)
  assert(type(tbl) == "table", "must of type table")
  assert(#tbl < 1024, "max limit is upto 1024")
  -- In case of qtype 'B1' ?
  assert(type(qtype) == "string" and base_qtype(qtype))
  
  local col = mk_col(tbl, qtype)
  return col
end

-- function to get table of vector values
fns.vector_to_table = function(vector)
  assert(type(vector) == "lVector", "must be of lVector")
  assert(vector:num_elements() < 1024, "max limit is upto 1024")
  local tbl = {} 
  
  for i = 1, vector:num_elements() do
    local value = c_to_txt(vector,i)
    tbl[#tbl+1] = value
  end

  return tbl
end

-- Note: qc.RDTSC() returns CPU cycles (not CPU time)
-- to get CPU time we need to calculate as follows:
-- Time = CPU cycles / CPU frequency (MHz)
-- RDTSC function performs this calculation and returns CPU time
fns.RDTSC = function(cpu_cycles)
  -- command to get cpu frequency (in MHz)
  local handle = io.popen("lscpu | grep MHz")
  local result = handle:read()
  -- to get cpy freq(number) from string
  local cpu_frequency = tonumber(string.match(result, "%d+"))
  handle:close()
  -- as cpu_frequency is in MHz so * by 1000000
  local time = cpu_cycles / (cpu_frequency * 1000000)
  return time
end
 
-- function to find an entry(value) in table
-- which returns index of value
fns.table_find = function(tbl, entry)
  assert(type(tbl) == "table", "input type is not table")
  assert(#tbl>0, "table should have values")
  for i = 1, #tbl do
    if (tbl[i] == entry) then
      return i
    end
  end
  return nil
end

-- round the number to specified precision
fns.round_num = function(num, precision)
  local mult = 10^(precision or 0)
  result = math.floor( num * mult + 0.5 ) / mult
  return result
end

return fns
