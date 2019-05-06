local Q       = require 'Q'
local plpath  = require 'pl.path'

-- Creates meta data for X and y 
local function cols(num_cols, suff)
  local x_cols = {}
  for i = 1, num_cols do
    local xname = 'x_' .. i .. suff
    x_cols[i] = { name = xname, qtype = "F8", has_nulls = false}
  end
  local yname = 'y_' ..  suff
  local y_cols = { { name = yname, qtype = "F8", has_nulls = false}}
  return x_cols, y_cols
end

local function load_data(
  data_file,  
--[[ name of TGZ file containing data 
  when expanded, data file will yield 4 files 
    'train_data.csv'
    'train_labels.csv'
    'test_data.csv'
    'test_labels.csv'
]]--
  num_cols -- number of columns in train-data
)
  -- uncompress files into 
  assert(plpath.isfile(data_file))
  local data_folder = './data'
  status = os.execute('mkdir -p ' .. data_folder)
  assert(status)
  assert(plpath.isdir(data_folder))
  status = os.execute('tar -xzf '.. data_file .. ' -C ' .. data_folder)
  assert(status)

  local prefix = data_folder .. '/' 
  local train_X_file = prefix .. 'train_data.csv'
  local train_y_file = prefix .. 'train_labels.csv'
  local test_X_file  = prefix .. 'test_data.csv'
  local test_y_file  = prefix .. 'test_labels.csv'
  assert(plpath.isfile(train_X_file))
  assert(plpath.isfile(train_y_file))
  assert(plpath.isfile(test_X_file))
  assert(plpath.isfile(test_y_file))

  local x_cols, y_cols = cols(num_cols, 'train')
  train_X = Q.load_csv(train_X_file, x_cols)
  train_y = Q.load_csv(train_y_file, y_cols)[1]
    
  x_cols, y_cols = cols(num_cols, 'test')
  test_X = Q.load_csv(test_X_file, x_cols)
  test_y = Q.load_csv(test_y_file, y_cols)[1]
  return train_X, train_y, test_X, test_y
end
return load_data
