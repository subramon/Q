local g_err	= require 'Q/UTILS/lua/error_code'

local fns = {}

local function clone (t) -- deep-copy a table
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
fns.clone = clone

--[[ Following contains one liner example of useful tasks, which should be used directly

- trim the string : stringx.strip(string_data)
- create lua table from string :  table =  pretty.read(table_in_string)
- dump whole content of table for debugging : pretty.dump(table)
- check file size : path.getsize(filepath)

-- ]]

-- function to get table length
fns.table_length= function(tbl)

  local count = 0
  for _, _ in pairs(tbl) do
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
  for _, v in pairs(sort_order) do
    -- order table string name should match cols table string index
    -- assert(type(v) == "string", "sort_order table value is not of type string")
    assert(cols[v]~= nil, g_err.INCORRECT_COLUMN_NAME_IN_SORT_ORDER)
    sorted_cols[#sorted_cols + 1] = cols[v]
  end

  return sorted_cols

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
  local result = math.floor( num * mult + 0.5 ) / mult
  return result
end

return fns
