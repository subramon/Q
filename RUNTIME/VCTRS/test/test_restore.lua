require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'
local max_num_in_chunk = get_max_num_in_chunk()
local len = 2 * max_num_in_chunk + 3 
assert(type(x) == "lVector")
assert(x:qtype() == "I4")
assert(x:num_elements() == len)
print("Completed test_restore")
