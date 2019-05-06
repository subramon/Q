local plpath = require 'pl.path'
local function testcase_results (v, test_for, test_type, result, spare)
  
  local date = os.date("%d/%m/%Y")
  local time = os.date("%H:%M")
  
  local dir_path = plpath.currentdir()
  dir_path = dir_path.."/"
  -- find start and end index of /Q/ or //Q//in dir path to get relative path from Q
  local start_index, end_index 
  start_index, end_index = string.find(dir_path, "[\\/]+Q[\\/]+")
  -- remove /Q/ or //Q//  
  local req_path = string.sub(dir_path, end_index)
  -- search if one more /Q/ or //Q// folder exists and remove it
  start_index, end_index = string.find(req_path, "[\\/]+Q[\\/]+")
  if end_index~=nil then req_path = string.sub(req_path, end_index+1) else req_path = string.sub(req_path, 2) end
  
  -- test case status is derived from result paramater 
  -- whether it is true or false
  local test_status
  if result then test_status = "SUCCESS" else test_status = "FAILURE" end
  
  print(string.format("%s%s %s ; %s ; %s ; %s ; %s ; %s ; %s \n",
    "__Q_TEST__", date, time, req_path, test_for, v.name, test_type , spare, test_status))
  -- print("__Q_TEST__"..date_time.." ; "..req_path.." ; LOAD_CSV ; "..v.name.." ; UNIT TEST ; SUCCESS \n")
end

return testcase_results
