local Q		= require 'Q'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local qc	= require 'Q/UTILS/lua/q_core'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local plpath        = require 'pl.path'

-- temporary function for writing headers
local function write_hdrs_to_train_test(train_file, test_file, hdr_info)
  local lines_train = {}
  local lines_test = {}
  for line in io.lines(train_file) do
    lines_train[#lines_train + 1] = line
  end
  for line in io.lines(test_file) do
    lines_test[#lines_test + 1] = line
  end

  local fp_train = io.open(train_file, "w")
  local fp_test  = io.open(test_file, "w")
  fp_train:write(hdr_info .. "\n")
  fp_test:write(hdr_info .. "\n")
  for i=1, #lines_train do
    fp_train:write(lines_train[i] .. "\n")
  end
  for i=1, #lines_test do
    fp_test:write(lines_test[i] .. "\n")
  end
  fp_train:close()
  fp_test:close()
end

-- hdr_info: a temporary arg to this split_csv --TODO
local function split_csv(data_file, meta_data_file, args, hdr_info)
  
  assert(data_file, "csv file not provided")
  assert(meta_data_file, "metadata file not provided")
  local split_ratio = 0.5
  if args.split_ratio then
    assert(type(args.split_ratio) == "number")
    assert(args.split_ratio < 1 and args.split_ratio > 0)
    split_ratio = args.split_ratio
  end
  assert(split_ratio < 1 and split_ratio > 0)
  
  local feature_of_interest
  if args.feature_of_interest then
    assert(type(args.feature_of_interest) == "table")
    feature_of_interest = args.feature_of_interest
  end
  
  local seed = 100
  -- loading the input csv datafile
  local T = Q.load_csv(data_file, dofile(meta_data_file), { is_hdr = args.is_hdr })
  
  -- splitting the loaded csv file into train & test
  local Train, Test = split_train_test(T, split_ratio, feature_of_interest, 100)
  
  -- printing the train & test data into separate csv files
  -- getting the print_csv opt_args 'print_order' field from metadata file
  local print_order = {}
  local M = dofile(meta_data_file)
  for i=1,#M do
    print_order[#print_order+1] = M[i].name
  end
  -- TODO: instead of penlight, use string function
  local dest_path, file_name = plpath.splitpath(data_file)
  local file_n = plpath.splitext(file_name)
  local train_filename = dest_path .. "/" .. file_n .. "_train.csv"
  local test_filename  = dest_path .. "/" .. file_n .. "_test.csv"
  Q.print_csv(Train, {opfile = train_filename, print_order = print_order })
  Q.print_csv(Test,  {opfile = test_filename, print_order = print_order })
  -- TODO: temporary function to write headers in train and test datafiles
  write_hdrs_to_train_test(train_filename, test_filename, hdr_info)

end

return split_csv
