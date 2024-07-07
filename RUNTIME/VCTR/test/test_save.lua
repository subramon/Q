local pldir = require 'pl.dir'
require 'Q/UTILS/lua/strict'
local lgutils = require 'liblgutils'
local Q = require 'Q'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'
local is_in = require 'Q/UTILS/lua/is_in'
local max_num_in_chunk = get_max_num_in_chunk()
local len = 2 * max_num_in_chunk + 3 
x = Q.const({ val = 1, qtype = "I4", len = len}):set_name("XX"):eval()
assert(x:ref_count() == 1)
assert(Q.save())
assert(x:ref_count() == 1)
x:nop()
local ddir = lgutils.data_dir()
local data_files = pldir.getfiles(ddir)
local exp_files = {
"/home/subramon/local/Q/data/_100000_000000", 
"/home/subramon/local/Q/data/_100000_100000", 
"/home/subramon/local/Q/data/_100000_200000", 
}

assert(#data_files == #exp_files)
for k1, v1 in pairs(data_files) do 
  assert(is_in(v1, exp_files))
end
print("Completed test_save")
