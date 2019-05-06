-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local plpath = require 'pl.path'
local plstring = require 'pl.stringx'
local validate_meta = require 'Q/OPERATORS/LOAD_CSV/lua/validate_meta'

--_G["Q_META_DATA_DIR"] = "./metadata"
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test/testcases"

local tests = {}

local T = dofile(script_dir .."/meta_data.lua")
local failed_testcases = {}

for i, m in ipairs(T) do
  assert(m.testcase_no,"Specify testcase_no in map file for '" .. m.meta .. "' testcase")
  
  tests[m.testcase_no] = function()
    print("Testing " .. m.meta)
    local M = dofile(script_dir .."/metadata/"..m.meta)
    local status, ret = pcall(validate_meta, M)
    --local status, ret = validate_meta(M)
    if ( not status ) then 
      assert(m.output_regex,"output regex is not specified")
      -- ret contain string in the format <filepath>:<line_num>:<error_msg>
      -- below line extract error_msge from ret and put in err variable
      local a, b, err= plstring.splitv(ret,':')
      -- trim whitespace required below, as splitv returned string with whitespace
      err = plstring.strip(err)
      
      -- output_regex contain the error message expected returned by validate_metadata
      local error_msg = m.output_regex 
      -- print("actual error", err)
      -- print("expected error", error_msg)
      
      -- match actual error msg with expected error msg
      assert(err == error_msg, "Actual and Expected error are different")
   
    else
      --print(i,"Testing success   " .. m.meta)
      assert(m.output_regex == nil)
    end
  end
end

return tests
