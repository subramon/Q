-- Substitutes string "${tmpl}" in input file with string <pattern>
-- to create output file 
local do_subs = require 'Q/UTILS/lua/do_subs'
local pattern = "${tmpl}"

local replace_by = assert(arg[1])
assert(type(replace_by) == "string")
assert(#replace_by > 0)

local infile = assert(arg[2])
local outfile = assert(arg[3])
assert(infile~= outfile)

local subs = {}
subs[pattern] = replace_by
do_subs(infile, outfile, subs)

