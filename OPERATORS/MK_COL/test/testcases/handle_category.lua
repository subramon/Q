local Q = require 'Q'
local plstring = require 'pl.stringx'
local qconsts = require 'Q/UTILS/lua/q_consts'
local convert_c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local print_csv = require 'Q/OPERATORS/PRINT/lua/print_csv'

local fns = {}

fns.increment_failed_mkcol = function (index, v, str)
  print("testcase name :"..v.name)
  print("qtype: "..v.qtype)
  print("reason for failure "..str)
end

--[[
fns.print_result = function () 
  local str
  str = "----------MK_COL TEST CASES RESULT----------------\n"
  str = str.."No of successfull testcases "..number_of_testcases_passed.."\n"
  str = str.."No of failure testcases     "..number_of_testcases_failed.."\n"
  str = str.."-----------------------------------\n"
  str = str.."Testcases failed are     \n"
  for k,v in ipairs(failed_testcases) do
    str = str..v.."\n"
  end
  str = str.."Run bash test_mkcol.sh <testcase_number> for details\n\n"
  str = str.."-----------------------------------\n"
  print(str)
  local file = assert(io.open("nightly_build_mkcol.txt", "w"), "Nighty build file open error")
  assert(io.output(file), "Nightly build file write error")
  assert(io.write(str), "Nightly build file write error")
  assert(io.close(file), "Nighty build file close error")
end
]]

fns.category1 = function (index, v, status, ret)
  -- print(ret)
  -- print(v.name)
  if status ~= false then
    fns["increment_failed_mkcol"](index, v, "Mk_col function does not return status = false")
    return false
  end
  
  if v.output_regex == nil then
    fns["increment_failed_mkcol"](index, v, "MK_Col : Output regex not given in category1 testcases")
    return false
  end
  
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  
  -- trimming whitespace
  local error_msg = plstring.strip(v.output_regex) -- check it can be used from utils.
  local count = plstring.count(err, error_msg)

  if count > 0 then
    return true
  else
    fns["increment_failed_mkcol"](index, v, "testcase category1 failed , actual and expected error message does not match")
    -- print("actual output:"..err)
    -- print("expected output:"..error_msg)
  end
end

fns.category2 = function (index, v, status, ret)
  -- print(ret)
  
  if status ~= true then
    fns["increment_failed_mkcol"](index, v, "Mk_col function does not return status = true")
    return false
  end
  
  if type(ret) ~= 'lVector' then
    fns["increment_failed_mkcol"](index, v, "Mk_col function does not return lVector")
    return false
  end
    
  for i=1,ret:length() do  
    local status, result = pcall(convert_c_to_txt, ret, i)
    assert(status, "Failed to get the value from vector at index: "..tostring(i))
    if result == nil then 
      if ret:qtype() == "B1" then result = 0 else result = "" end
    end
    local is_float = ret:qtype() == "F4" or ret:qtype() == "F8"
    -- to handle the extra decimal values put in case of Float
    if is_float then
      local precision = v.precision
      precision = math.pow(10,precision)
      result = precision * result
      result = math.floor(result)
      result = result / precision
    end
    
    -- print(result , v.input[i])
    if result ~= v.input[i] then
      fns["increment_failed_mkcol"](index, v, "Mk_col input output mismatch input = "..v.input[i]..
        " output = "..result)
      return false
    end
    
  end
  -- print("Testing successful ", v.name)
  return true
end

fns.category3 = function (index, v, status, ret)
  --print(ret)
  
  if status ~= true then
    fns["increment_failed_mkcol"](index, v, "Mk_col function does not return status = true")
    return false
  end
  
  if type(ret) ~= 'lVector' then
    fns["increment_failed_mkcol"](index, v, "Mk_col function does not return lVector")
    return false
  end
  local opt_args = { opfile = "" }
  local status, expected_str = pcall(print_csv, ret, opt_args)
  assert(status,"Reason of failure" .. expected_str )
  -- converting table to string
  local actual_str = table.concat(v.input, "\n")
  actual_str = actual_str .. "\n"
  
  print(actual_str,expected_str)
  if actual_str ~= expected_str then
    fns["increment_failed_mkcol"](index, v, "Mk_col input output mismatch input = ".. actual_str ..
      " output = "..expected_str)
    return false
  end
  
  return true
end
return fns