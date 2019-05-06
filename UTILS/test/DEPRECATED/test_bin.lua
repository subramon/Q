local lVector = require 'Q/RUNTIME/lua/lVector'
local Q = require 'Q'
local vec = lVector({qtype = "I8", file_name = "mybin.bin", has_nulls = false})
vec:persist(true)
Q.print_csv(vec)
