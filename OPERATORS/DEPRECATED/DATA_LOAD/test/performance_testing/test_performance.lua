local dir = require 'pl.dir'
local fns = require 'Q/OPERATORS/DATA_LOAD/test/performance_testing/gen_csv_metadata_file'
local load_csv = require 'Q/OPERATORS/DATA_LOAD/lua/load_csv_dataload'
local utils = require 'Q/UTILS/lua/utils'

-- file in which performance testing results for each csv file is written
local performance_file ="./performance_results/performance_measures.txt"
local meta_info_dir_path = "./meta_info/"

dir.makepath("./performance_results/")
--set environment variables for test-case
-- _G["Q_DATA_DIR"] = "./test_data/out/"
-- _G["Q_META_DATA_DIR"] = "./test_data/metadata/"
-- _G["Q_DICTIONARIES"] = {}
  
-- dir.makepath(_G["Q_DATA_DIR"])
-- dir.makepath(_G["Q_META_DATA_DIR"])

-- opening the performance result file
local filep = assert(io.open(performance_file, 'a')) -- append mode so that all testcases writes their result in this file
local date = os.date("%d.%m.%Y")
filep:write("Performance testing results on: "..date.."\n")
filep:write("Rows \t Columns \t Testcase \t\t\t Execution time(in secs) \t Time \n")
filep:close()


local T = dofile("map_meta_info_data.lua")
for i, v in ipairs(T) do
  
  _G["Q_DICTIONARIES"] = {}
  filep = assert(io.open(performance_file, 'a')) -- append mode so that all testcases writes their result in this file
  print("Testing "..v.name)
  
  local M = dofile(meta_info_dir_path..v.meta_info)
  
  -- generating maximum dictionary size unique strings
  local unique_string_tables = fns["generate_unique_varchar_strings"](M)
  -- generate metadata table which is to be passed to load csv
  local metadata_table = fns["generate_metadata"](M)
  
  local csv_file_path = v.data -- taking csv file name from map_meta_info_data file
  local row_count = v.row_count  -- no of rows you wish to enter
  local chunk_print_size = v.chunk_print_size  -- writing data into files as chunks(i.e. chunk size)
  
  --need to provide csv_file_name, columns_list, no_of_rows, chunk_print_size and unique_str_table(if varchar column exists)
  fns["generate_csv_file"](csv_file_path, metadata_table, row_count, chunk_print_size,unique_string_tables)
  
  --checking execution time required for load_csv function
  local start_time = os.time()
  local ret = load_csv(csv_file_path, metadata_table)
  local end_time = os.time()
  local date = (os.date ("%r")) 
  
  -- writing results in performance_result file
  filep:write(string.format("%d \t %d \t\t\t %s \t\t\t %.2f secs \t\t\t\t\t\t\t %s \n", row_count, #metadata_table, v.name, end_time-start_time, date))
  
  -- calling standard output function
  local result
  if type(ret) == "table" then result = true else result = false end
  utils["testcase_results"](v, "test_performance.lua", "Data_load Performance Testing", "Performance Testing", result, "")
  
  -- delete respective csv file
  file.delete(csv_file_path) 
  
  print("Results written in performance_results file\n")
  print("--------------------------------------------")
  filep:close()
  
end  

-- clear the output directory 
-- dir.rmtree(_G["Q_DATA_DIR"])
-- dir.rmtree(_G["Q_META_DATA_DIR"])