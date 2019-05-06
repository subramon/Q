local split = require 'Q/ML/UTILS/lua/split_csv_to_train_test'

local function split_data()
  local data_file = "ds3.csv"
  local metadata_file = "ds3_meta.lua"
  local split_csv_args = {}
  split_csv_args.is_hdr = true
  local hdr_info = "f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16,f17,f18,f19,y"
  split(data_file, metadata_file, split_csv_args, hdr_info)
  print("Done")
end

split_data()
