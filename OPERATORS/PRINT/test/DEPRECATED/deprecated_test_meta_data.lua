local validate_meta =  require("validate_meta")
_G["Q_META_DATA_DIR"] = "./metadata"

local no_of_success = 0
local no_of_failure = 0
local T = dofile("meta_data.lua")
local failed_testcases = {}

for i, gm in ipairs(T) do
  if arg[1]~= nil and tonumber(arg[1])~=i then goto skip end
  print("Testing " .. gm)
  M = dofile("test_metadata/"..gm)
  local status, err = pcall(validate_meta, M)
  --validate_meta(M)
  
  if ( not status ) then 
    print("Error:", err)
    no_of_failure = no_of_failure + 1
    table.insert(failed_testcases,i)
  else
    if gm.output_regex then
      no_of_failure = no_of_failure + 1
      table.insert(failed_testcases,i)
    else
      no_of_success = no_of_success + 1
    end
  end
  
  ::skip::
end

local str
str = "-------METADATA TEST CASES-------------\n"
str = str.."No of successfull testcases "..no_of_success.."\n"
str = str.."No of failure testcases     "..no_of_failure.."\n"
str = str.."-----------------------------------\n"

if #failed_testcases > 0 then
  str = str.."---run bash test_meta_data.sh <testcase_number> for more details -------\n"
  str = str.."---Testcases failed are -------\n"
end

for i=1,#failed_testcases do
  str = str..failed_testcases[i].."\n"
end

print(str)