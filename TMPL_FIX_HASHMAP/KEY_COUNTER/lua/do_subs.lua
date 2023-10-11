local just_do_subs = require 'just_do_subs'
assert(type(arg) == "table")
local label   = assert(arg[1])
local infile  = assert(arg[2])
local outfile = assert(arg[3])
-- print("label   = ", label)
-- print("infile  = ", infile)
-- print("outfile = ", outfile)
just_do_subs(label, infile, outfile)
