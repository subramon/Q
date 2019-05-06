-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local plpath = require 'pl.path'
local plstring = require 'pl.stringx'
local validate_meta = require 'Q/OPERATORS/LOAD_CSV/lua/validate_meta'

--_G["Q_META_DATA_DIR"] = "./metadata"
local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local no_of_success = 0
local no_of_failure = 0
local T = dofile(script_dir .."/meta_data.lua")
local failed_testcases = {}

for i, m in ipairs(T) do
  
  if arg[1]~= nil and tonumber(arg[1])~=i then goto skip end
  print(i,"Testing " .. m.meta)
  local M = dofile(script_dir .."/test_metadata/"..m.meta)
  local status, ret = pcall(validate_meta, M)
  --local status, ret = validate_meta(M)
  if ( not status ) then 
    if m.output_regex == nil then
      no_of_failure = no_of_failure + 1
      table.insert(failed_testcases,i)
    else
      -- ret contain string in the format <filepath>:<line_num>:<error_msg>
      -- below line extract error_msge from ret and put in err variable
      local a, b, err= plstring.splitv(ret,':')
      -- trim whitespace required below, as splitv returned string with whitespace
      err = plstring.strip(err)
      
      -- output_regex contain the error message expected returned by validate_metadata
      local error_msg = m.output_regex 
      print("actual error", err)
      print("expected error", error_msg)
      -- match actual error msg with expected error msg
      if err == error_msg then
        no_of_success = no_of_success + 1
      else
        no_of_failure = no_of_failure + 1
        table.insert(failed_testcases,i)
      end
    end
  else
    --print(i,"Testing success   " .. m.meta)
    if m.output_regex then
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
local file = assert(io.open("nightly_build_metadata.txt", "w"), "Nighty build file open error")
assert(io.output(file), "Nightly build file write error")
assert(io.write(str), "Nightly build file write error")
assert(io.close(file), "Nighty build file close error")

require('Q/UTILS/lua/cleanup')()
os.exit()

