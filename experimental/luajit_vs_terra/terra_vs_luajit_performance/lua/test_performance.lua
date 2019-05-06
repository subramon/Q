local use_terra = false
if arg[2] then
  if string.lower(arg[2]) == "true" then
    use_terra = true
  end
end
if use_terra then
  print("Using terra library")
  require 'terra'
end
_G["Q_DICTIONARIES"] = {}
local dir = require 'pl.dir'
local load_csv = require 'load_csv'
local gen_csv = require 'gen_csv_metadata_file'

_G["Q_DATA_DIR"] = "./test_data/out/"
_G["Q_META_DATA_DIR"] = "./test_data/metadata/"
  
dir.makepath(_G["Q_DATA_DIR"])
dir.makepath(_G["Q_META_DATA_DIR"])


_G["Q_DICTIONARIES"] = {}
metadata_file_path = "./meta_info/meta_info_1mr_256c.lua" 
local M = dofile(metadata_file_path)
  
local metadata_table = gen_csv.generate_metadata(M)
local csv_file_path = arg[1]
local start_time = os.time()
local ret = load_csv(csv_file_path, metadata_table)
local end_time = os.time()
  
local result
if type(ret) == "table" then 
  print("Load CSV Performance Test Result: SUCCESS")
  print(string.format("Load Operation Time: %.2f secs", end_time-start_time))
else
  print("Load CSV Performance Test Result: FAILED")
end
print("--------------------------------------------")
  


-- clear the output directory 
dir.rmtree(_G["Q_DATA_DIR"])
dir.rmtree(_G["Q_META_DATA_DIR"])
