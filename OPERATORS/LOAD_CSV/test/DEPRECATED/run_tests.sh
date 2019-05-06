export LD_LIBRARY_PATH="$LD_LIBRARY_PATH;./;../../../RUNTIME/COLUMN/code/"
luajit test_good_data.lua good_data.lua
lua test_good_meta_data.lua good_meta_data.lua
