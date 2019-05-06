local Q = require 'Q'
local plstring = require 'pl.stringx'
local Vector = require 'Q/RUNTIME/lua/lVector'
local lVector = require 'Q/RUNTIME/lua/lVector'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
local print_csv = require 'Q/OPERATORS/PRINT/lua/print_csv'
local convert_c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local qconsts = require 'Q/UTILS/lua/q_consts'
local file = require 'pl.file'
local plpath = require 'pl.path'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/PRINT/test"

local fns = {}

fns.increment_failed = function (index, v, str)
  print("testcase name :"..v.name)
  print("Meta file: "..v.meta)
  if v.data then
    print("csv file: "..v.data)
  end
  print("reason for failure "..str)
  --[[
  print("\n-----Meta Data File------\n")
  os.execute("cat "..rootdir.."/OPERATORS/PRINT/test/metadata/"..v.meta)
  print("\n\n-----CSV File-------\n")
  os.execute("cat "..rootdir.."/OPERATORS/PRINT/test/data/"..v.data)
  print("\n--------------------\n")
  ]]--
end

-- match file1 and file2, return true if success
local file_match = function (file1, file2)
  local expected_file_content = file.read(file1)
  local actual_file_content = file.read(file2)
  -- print(actual_file_content)
  -- print(expected_file_content)
  if actual_file_content ~= expected_file_content then
     return false
  end
  return true
end

-- original data -> load -> print -> Data A -> load -> print -> Data B. 
-- In this function Data A is matched with Data B 
local check_again = function (index, csv_file, meta, v)
  local M = dofile(script_dir .."/metadata/"..meta)
  -- print(csv_file)
  local status_load, load_ret = pcall(load_csv,csv_file, M, {use_accelerator = false})
  if status_load == false then
    fns["increment_failed"](index, v, "testcase failed: in category1, output of load_csv fail in second attempt")
    return false
  end
  
  v.opt_args['opfile'] = csv_file .. ".output" 
  local status_print, print_ret = pcall(print_csv, load_ret, v.opt_args )
  if status_print == false then
    fns["increment_failed"](index, v, "testcase failed: in category1, output of print_csv fail in second attempt")
    return false
  end
  
  if file_match(csv_file, csv_file .. ".output") == false then
    fns["increment_failed"](index, v, "testcase failed: in category1, input and output csv file does not match in second attempt")
    return false
  end
  
  return true
end

-- in this category input file to load_csv and output file from print_csv is matched
fns.handle_category1 = function (index, v, ret, status)
  --print(v.name)
  --print(status)
  -- if status returned is false then this testcase has failed
  if not status then
    print(ret)
    fns["increment_failed"](index, v, "testcase failed: in category1, output of print_csv is not success")
    return false
  end
  
  if type(ret) == "string" then
    fns["increment_failed"](index, v, "testcase failed: in category1, output of print_csv is a string")
    return false
  end
  
  -- match input and output files
  if file_match(script_dir .."/data/"..v.data, v.opt_args['opfile']) == false then
     fns["increment_failed"](index, v, "testcase failed: in category1, input and output csv file does not match")
     return false
  end
  --number_of_testcases_passed = number_of_testcases_passed + 1

  -- original data -> load -> print -> Data A -> load -> print -> Data B. 
  -- In this function Data A is matched with Data B 
  return check_again(index, v.opt_args['opfile'], v.meta, v)
end

fns.handle_category1_1 = function (index, v, ret, status)
  
  if not status then
    print(ret)
    fns["increment_failed"](index, v, "testcase failed: in category1_1, output of print_csv is not success")
    return false
  end
  
  if type(ret) == "string" then
    fns["increment_failed"](index, v, "testcase failed: in category1_1, output of print_csv is a string")
    return false
  end
  
  -- match input and output files
  if file_match(script_dir .."/data/"..v.data, v.opt_args['opfile']) == false then
     fns["increment_failed"](index, v, "testcase failed: in category1_1, input and output csv file does not match")
     return false
  end
  return true
end

fns.handle_category1_2 = function (index, v, ret, status, exp_load_ret)
  
  if not status then
    print(ret)
    fns["increment_failed"](index, v, "testcase failed: in category1_1, output of print_csv is not success")
    return false
  end
  
  if type(ret) == "string" then
    fns["increment_failed"](index, v, "testcase failed: in category1_1, output of print_csv is a string")
    return false
  end
  
  -- checking load_csv returned table for type
  assert(type(exp_load_ret) == "table", "load_ret is not of type table")
  for _, col in pairs(exp_load_ret) do
    assert(type(col) == "lVector", "must be of type lVector")
  end
  -- loading csv file outputed by print_csv
  local metadata = dofile(script_dir .. "/metadata/" .. v.meta)
  local csv_file = v.opt_args['opfile']
  local load_status, actual_load_ret = pcall(load_csv, csv_file, metadata, {use_accelerator = false})
  -- checking actual and expected vector elements using vveq operator
  for idx in pairs(exp_load_ret) do
    local eq = Q.vveq(actual_load_ret[idx], exp_load_ret[idx])
    -- checking results by using sum operator (as sum must be equal to  num_elements
    assert(Q.sum(eq):eval():to_num() == exp_load_ret[idx]:num_elements(), "Actual and expected element not matching")
  end
  
  return true
end

fns.handle_category1_3 = function (index, v, ret, status)

  if not status then
    print(ret)
    fns["increment_failed"](index, v, "testcase failed: in category1_1, output of print_csv is not success")
    return false
  end

  if type(ret) == "string" then
    fns["increment_failed"](index, v, "testcase failed: in category1_1, output of print_csv is a string")
    return false
  end

  -- match input and output contents
  local expected_content = v.output_regex
  local actual_content = file.read(v.opt_args['opfile'])
  if actual_content ~= expected_content then
     fns["increment_failed"](index, v, "testcase failed: in category1_1, input and output csv file does not match")
     return false
  end
  return true
end

-- this category matches output_regex(expected_value) with print_csv opfile contents  
fns.handle_category1_4 = function (index, v, ret, status)
  --print(v.name)
  --print(status)
  -- if status returned is false then this testcase has failed
  if not status then
    print(ret)
    fns["increment_failed"](index, v, "testcase failed: in category1_4, output of print_csv is not success")
    return false
  end
  
  if type(ret) == "string" then
    fns["increment_failed"](index, v, "testcase failed: in category1_4, output of print_csv is a string")
    return false
  end
  
  local expected_output_regex = v.output_regex
  local actual_file_content = file.read(v.opt_args['opfile'])
  
  if actual_file_content ~= expected_output_regex then
    fns["increment_failed"](index, v, "testcase failed: in category1_4, Mismatch in columns order")
    return false
  end
  
  return true
end


-- in this category invalid filter input are given 
-- output expected are error codes as mentioned in UTILS/error_code.lua file
fns.handle_category2 = function (index, v, ret, status)
  -- print(v.name) 
  
  if status or v.output_regex==nil then
    fns["increment_failed"](index, v, "testcase failed: in category2, output of print_csv should be false")
    return false
  end
  
  local actual_output = ret
  local expected_output = v.output_regex
  
  -- actual output is of format <filepath>:<line_number>:<error_msg>
  -- get the actual error message from the ret
  local a, b, err = plstring.splitv(actual_output,':')
  -- trimming whitespace if any
  err = plstring.strip(err) 
  --print("Actual error:"..err)
  --print("Expected error:"..expected_output)
  if err ~= expected_output then
     fns["increment_failed"](index, v, "testcase failed: in category2, actual and expected error message does  not match")
     return false
  end
  return true
end

-- vector of type I4 is given as filter input for category 4 testcases
fns.handle_input_category4 = function ()
  local v1 = Vector{qtype='I4',
    file_name= script_dir .."/bin/I4.bin",  
  }
  v1:persist(true)
  return { where = v1 }
end

-- vector of type B1 is given as filter input for category 3 testcases
fns.handle_input_category3 = function ()
  local v1 = Vector{qtype='B1', num_elements=4,
    file_name= script_dir .."/bin/B1.bin",  
  }
  v1:persist(true)
  return { where = v1 }
end

-- in this category expected output is FILTER_INVALID_FIELD_TYPE
fns.handle_category4 = function (index, v, ret, status)
  --print(v.name) 
  
  if status then
    fns["increment_failed"](index, v, "testcase failed: in category4, output of print_csv should be false")
    return false
  end
  
  local expected_output = v.output_regex
   
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  --print("Actual error:"..err)
  --print("Expected error:"..expected_output)
  
  if err ~= expected_output then
     fns["increment_failed"](index, v, "testcase failed: in category 4, actual and expected error does  not match")
     return false
  end
   return true
end

-- in this testcase bit vector is given as input 
-- the output of csv file will be only those elements 
-- whose bits are set in the bit vector
fns.handle_category3 = function (index, v, ret, status)
  -- print(v.name) 
  
  if not status then
    -- print(ret)
    fns["increment_failed"](index, v, "testcase failed: in category3, output of print_csv should be true")
    return false
  end
  
  local expected_file_content = file.read(v.opt_args['opfile'])
  --print(expected_file_content)
  --print(v.output_regex)
  if v.output_regex ~= expected_file_content then
     fns["increment_failed"](index, v, "testcase failed: in category 3, actual and expected output does  not match")
     return false
  end
  
  return true
end

-- in this testcase range filter is given as input
-- the output of print_csv would be only those elements which fall between lower and upper range
fns.handle_category5 = function (index, v, ret, status)
  -- print(v.name) 
  
  if not status then
    -- print(ret)
    fns["increment_failed"](index, v, "testcase failed: in category5, output of print_csv should be true")
    return false
  end
  
  local expected_file_content = file.read(v.opt_args['opfile'])
  
  --print(expected_file_content)
  --print(v.output_regex)
  if v.output_regex ~= expected_file_content then
     fns["increment_failed"](index, v, "testcase failed: in category 5, actual and expected output does  not match")
     return false
  end
  
  return true
end

-- in this testcase, the output csv file from print_csv should be consumable to load_csv
fns.handle_category6 = function (index, v, M)
  -- print(v.name)

  local col = lVector{qtype='I4',
    file_name= script_dir .."/bin/I4.bin",  
  }
  col:persist(true) 
  local arr = {col}
  --print_csv(arr, { opfile = script_dir .. "testcase_consumable.csv"} )
  local filename = qconsts.Q_DATA_DIR .. "/_" .. M[1].name
  local status, print_ret = pcall(print_csv, arr, v.opt_args )
  if status then
    local csv_file = v.opt_args['opfile']
    local status, load_ret = pcall(load_csv, csv_file, M, {use_accelerator = false})
    filename = load_ret[M[1].name]:meta().base.file_name
  end
  -- local filename = _G["Q_DATA_DIR"].."_"..M[1].name
  --print(filename) /home/pragati/Q/DATA_DIR/
  
  local actual_file_content1 = file.read(script_dir .."/bin/I4.bin")
  local actual_file_content2 = file.read(filename)
  if actual_file_content1 ~= actual_file_content2 then  
    fns["increment_failed"](index, v, "testcase failed: in category 6, input and output bin files does  not match")
    return false
  end
  
  return true
end

-- in this testcase, the input file is not passed 
-- and a string is returned by print 
fns.handle_category7 = function (index, v,ret, status)
  --print(v.name) 
 
  -- if status returned is false then this testcase has failed
  if not status then
    fns["increment_failed"](index, v, "testcase failed: in category7, output of print_csv is not success")
    return false
  end
    
  if type(ret) ~= "string" then
    fns["increment_failed"](index, v, "testcase failed: in category7, output of print_csv is not string")
    return false
  end

  -- print("output regex = ",v.output_regex)
  if ret ~= v.output_regex then
    print(ret)
    print(v.output_regex)
    fns["increment_failed"](index, v, "testcase failed: in category7, output of print_csv does not match with output_regex")
    return false
  end
  
  return true
end

-- in this testcase, the input file passed is empty string
-- and the output is printed on stdout 
fns.handle_category8 = function (index, v,ret, status)
  --print(v.name) 
 
  -- if status returned is false then this testcase has failed
  if not status then
    fns["increment_failed"](index, v, "testcase failed: in category8, output of print_csv is not success")
    return false
  end

  return true
end

--[[
-- this function prints all the result
fns.print_result = function ()
  local str
  str = "----------PRINT TEST CASES RESULT----------------\n"
  str = str.."No of successfull testcases "..number_of_testcases_passed.."\n"
  str = str.."No of failure testcases     "..number_of_testcases_failed.."\n"
  str = str.."--------------------------------------------\n"
  if #failed_testcases > 0 then
    str = str.."Testcases failed are     \n"
    for k,v in ipairs(failed_testcases) do
      str = str..v.."\n"
    end
    str = str.."Run bash test_print_csv.sh <testcase_number> for details\n\n"
    str = str.."------------------------------------------\n"
  end
  print(str)
  local file = assert(io.open("nightly_build_print.txt", "w"), "Nighty build file open error")
  assert(io.output(file), "Nightly build file write error")
  assert(io.write(str), "Nightly build file write error")
  assert(io.close(file), "Nighty build file close error")
end
]]
return fns
