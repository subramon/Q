local plpath  = require 'pl.path'
local lVector = require 'Q/RUNTIME/lua/lVector'
local utils = require 'Q/UTILS/lua/utils'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/RUNTIME/test/lVector_test"

-- Negative testcase: materialized vector file not found
-- should fail for all qtypes as the bin file is not present
-- but not giving a desired result for qtype "I1"

local M = {
  file_name = "bin/in.bin",
  is_memo = true,
}

local tests = {} 
local all_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

for i in pairs(all_qtypes) do
  
  tests[i] = function()
    M.qtype = all_qtypes[i]
    M.file_name = script_dir .. "/" .. M.file_name
    print("----------------------------------------------------")
    print("Running testcase: file_not_found ".. M.qtype)
    print("START: Deliberate error attempt")
    local lvec_status, ret = pcall(lVector,  M)
    print("STOP : Deliberate error attempt")
    print("lVector return status:",lvec_status)
    assert(lvec_status == false)
    --[[
    if not status then
      print(ret)
      ret = nil
    end
     this testcase is a negative testcase 
    -- if it fails then testcase is passed
    local status
    if lvec_status == false then status = true else status = false end
    ]]
    --utils["testcase_results"]({ name = "file_not_found ".. M.qtype}, "lVector", "Unit Test", status, "")
  end
end

return tests