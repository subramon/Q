-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local dbg = require 'Q/UTILS/lua/debugger'
local load_csv = Q.load_csv

local tests = {}

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test"
local meta_data_file = script_dir .. "/good_data.lua"
local T = dofile(meta_data_file)

for i, v in ipairs(T) do
  
  tests[v.testcase_no] = function ()
    local meta_file, csv_file
    if not plpath.isabs(v.meta) then 
      meta_file = script_dir .."/".. v.meta
      csv_file = script_dir .."/".. v.data
    end
    local M = dofile(meta_file)
    local D = csv_file
    local status, err = pcall(load_csv, D, M)
    if ( not status ) then 
      error( "Failed testcase_no ".. v.testcase_no .. " Error: "..err)
    end
    print("testcase no: "..v.testcase_no .." name: ".. v.meta .." successful")
  end
end

return tests
