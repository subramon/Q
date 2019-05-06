local plstring = require 'pl.stringx'
local plfile = require 'pl.path'
local convert_c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local number_of_testcases_passed = 0
local number_of_testcases_failed = 0

local failed_testcases = {}

local fns = {}

fns.increment_failed_load = function (index, v, str)
  print("testcase name :"..v.name)
  print("Meta file: "..v.meta)
  print("csv file: "..v.data)
  
  print("reason for failure "..str)
  number_of_testcases_failed = number_of_testcases_failed + 1
  table.insert(failed_testcases,index)
  --[[
  print("\n-----Meta Data File------\n")
  os.execute("cat "..rootdir.."/OPERATORS/DATA_LOAD/test/testcases/test_metadata/"..v.meta)
  print("\n\n-----CSV File-------\n")
  os.execute("cat "..rootdir.."/OPERATORS/DATA_LOAD/test/testcases/test_data/"..v.data)
  print("\n--------------------\n")
  --]] 
end

fns.print_result = function () 
  local str
  
  str = "----------DATA_LOAD TEST CASES RESULT----------------\n"
  str = str.."No of successfull testcases "..number_of_testcases_passed.."\n"
  str = str.."No of failure testcases     "..number_of_testcases_failed.."\n"
  str = str.."-------------------------------------------------\n"
  if #failed_testcases > 0 then
    str = str.."Testcases failed are     \n"
    for k,v in ipairs(failed_testcases) do
      str = str..v.."\n"
    end
    str = str.."Run bash test_load_csv.sh <testcase_number> for details\n\n"
    str = str.."-----------------------------------------------\n"
  end
  print(str)
  local file = assert(io.open("nightly_build_load.txt", "w"), "Nighty build file open error")
  assert(io.output(file), "Nightly build file write error")
  assert(io.write(str), "Nightly build file write error")
  assert(io.close(file), "Nighty build file close error")
end

-- this function checks whether the output regex is present or not
-- it also checks the status returned by load.
-- for category 1 and category6, if status is false then only testcase will succeed
-- for category 2, category 3, category 4 and category 5
-- if status is true then only testcase will succeed

local handle_output_regex = function (index, status, v, flag, category)
  local output
  
  if flag then status = status else status = not status end
  -- in category 1 , status = status , flag = true . if status is true, testcase should fail
  -- in category 2,  status = not status, flag = false, if status is false, testcase should fail
  if status then
    print("status is ",status) 
    fns["increment_failed_load"](index, v, "testcase failed : in "..category.." , incorrect status value")
    return nil
  end
  
  -- output_regex should be present in map_metadata, 
  -- else testcase should fail
  if v.output_regex == nil then
    fns["increment_failed_load"](index, v, "testcase failed : in "..category.." , output regex nil")
    return nil
  end  
  
  output = v.output_regex
  return output
end
  
-- this function handle testcases where error messages are expected output 
fns.handle_category1 = function (index, status, ret, v)
  -- print(ret)
  -- print(v.name)
  local output = handle_output_regex(index, status, v, true, "category1")
  if output == nil then return false end
  
  -- ret is of format <filepath>:<line_number>:<error_msg>
  -- get the actual error message from the ret
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  
  -- trimming whitespace
  local error_msg = plstring.strip(output) -- check it can be used from utils.
  
  -- check this line can be skipped with the duplicate line below
  -- if error_msg is subset of err
  local count = plstring.count(err, error_msg)
  if count > 0 then
    number_of_testcases_passed = number_of_testcases_passed + 1 
    return true
  else
    fns["increment_failed_load"](index, v, "testcase category1 failed , actual and expected error message does not match")
    print("actual output:"..err)
    print("expected output:"..error_msg)
    return false
  end
end


-- this function handle testcases where table of columns are expected output 
-- in this table, only one column is present
fns.handle_category2 = function (index, status, ret, v, output_category3, v_category3)
  -- print(ret)
  local output

  if v then
    -- print(v.name)
    if type(ret) ~= "table" then
      fns["increment_failed_load"](index, v, "testcase failed: in category2 , output of load is not a table")
      return false
    end
    output = handle_output_regex(index, status, v, false, "category2")
    ret = ret[1]
  else
    v = v_category3
    output = output_category3
  end
  
  if output == nil then return false end
  
  if type(output) ~= "table" then
    fns["increment_failed_load"](index, v, "testcase failed: in category2 , output regex is not a table")
    return false
  end
  
  if type(ret) ~= "lVector" then
    fns["increment_failed_load"](index, v, "testcase failed: in category2 , output of load is not a column")
    return false
  end
  --print(ret[1])
  --print(ret:length())
  --print(#output)
  if ret:length() ~= #output then
    fns["increment_failed_load"](index, v, "testcase failed: in category2 , length of lVector and output regex does not match")
    return false
  end
  
  for i=1,ret:length() do
    local status, result = pcall(convert_c_to_txt,ret,i)
    
    if status == false then
      fns["increment_failed_load"](index, v, "testcase failed: in category2 "..result)
      return false
    end
    local is_SC = ret:fldtype() == "SC"    -- if field type is SC , then pass field size, else nil
    local is_SV = ret:fldtype() == "SV"    -- if field type is SV , then get value from dictionary
    
    local is_string = is_SC or is_SV
    if not is_string then 
      result = tonumber(result)
    end
    --print(result, output[i])
    -- if result is nil, then set to empty string
    if result == nil then result = "" end
    if result ~= output[i] then 
      fns["increment_failed_load"](index, v, "testcase category2 failed , \nresult="..result.." \noutput["..i.."]="..output[i].."\n")
      return false
    end
  end
  number_of_testcases_passed = number_of_testcases_passed + 1 
  return true
end

-- this function handle testcases where table of columns are expected output 
-- in this table, multiple columns are present
-- handle_category2 function is reused
-- it is called in loop for every column
fns.handle_category3 = function (index, status, ret, v)
  -- print(ret)
  -- print(v.name)
  local output = handle_output_regex(index, status, v, false, "category3")
  if output == nil then return false end
  
  if type(output) ~= "table" and type(ret) ~= "table" then
    fns["increment_failed_load"](index, v, "testcase failed: in category3 , output regex and output of load is not a table")
    return false
  end
  
  if #output ~= #ret then
    fns["increment_failed_load"](index, v, "testcase failed: in category3 , output regex length is not equal to  output of load ")
    return false
  end
  
  for i=1,#output do
    --print(type(ret[i]))
    local ret = fns.handle_category2(index, status, ret[i], nil, output[i], v)
    if not ret then return nil end
    number_of_testcases_passed = number_of_testcases_passed - 1
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
  return true
end

-- check the length of bin files in this testcase 
fns.handle_category4 = function (index, status, ret, v)
  -- print(ret)
  -- print(v.name)
  local output = handle_output_regex(index, status, v, false, "category4")
      
  if output == nil then return false end
  
  if type(output) ~= "table" and type(ret) ~= "table" then
    fns["increment_failed_load"](index, v, "testcase failed: in category4 , output regex and output of load is not a table")
    return false
  end
  local sum = {}
  for i=1,#ret do
    if type(ret[i]) ~= "lVector" then
      fns["increment_failed_load"](index, v, "testcase failed: in category4 , output of load is not a column")
      return false
    end
    sum[i] = ret[i]:length() * ret[i]:field_size()
    if sum[i] ~= output[i] then
      fns["increment_failed_load"](index, v, "testcase failed: in category4 , size of each column not matching with output regex")
      return false
    end
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
  return true
end

-- check whether the null file is present if has_null is true and csv file has no null values
-- if null file present , then load_csv api should delete that file
fns.handle_category5 = function (index, status, ret, v)
  -- print(ret)
  -- print(v.name)
  local output = handle_output_regex(index, status, v, false, "category5")
      
  if output == nil then return false end
  
  if type(ret) ~= "table" then
    fns["increment_failed_load"](index, v, "testcase failed: in category5 , output of load is not a table")
    return false
  end
  
  for i=1,#ret do
    if type(ret[i]) ~= "lVector" then
      fns["increment_failed_load"](index, v, "testcase failed: in category5 , output of load is not a column")
      return false
    end
  end
  
  local is_present = plfile.isfile(require('Q/q_export').Q_DATA_DIR .. "/_" .."_col2_nn")
  if is_present then
    fns["increment_failed_load"](index, v, "testcase failed: in category5 , null file still present in data directory")
    return false
  end

  number_of_testcases_passed = number_of_testcases_passed + 1
  return true
end

return fns
