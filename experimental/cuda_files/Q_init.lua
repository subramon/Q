-- requires luaposix have to include in our luarocks def
-- local stdlib = require("posix.stdlib")
-- CUDA: Current focus is on f1f2opf3
-- require all the root operator files
require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
require "Q/OPERATORS/PRINT/lua/print_csv"
require "Q/UTILS/lua/save"
require "Q/UTILS/lua/restore"
require "Q/UTILS/lua/q_shutdown"
require "Q/UTILS/lua/view_meta"
require "Q/OPERATORS/F1F2OPF3/lua/_f1f2opf3"
require 'libsclr'

return require 'Q/q_export'
