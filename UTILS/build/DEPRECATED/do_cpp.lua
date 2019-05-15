local cpp = require 'Q/UTILS/lua/cpp'

local nargs = assert(#arg == 2, "Arguments are <infile> <outfile>")
local infile = arg[1]
local outfile = arg[2]
cpp(infile, outfile)
