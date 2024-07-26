local pldir = require 'pl.dir'
require 'Q/UTILS/lua/strict'
local lgutils = require 'liblgutils'
local cutils = require 'libcutils'
local Q = require 'Q'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'
local is_in = require 'RSUTILS/lua/is_in'
local max_num_in_chunk = get_max_num_in_chunk()
local len = 2 * max_num_in_chunk + 3 
x = Q.const({ val = 1, qtype = "I4", len = len}):set_name("XX"):eval()
x:nop()
y = x -- expect to see a reference to x and y in q_meta
assert(Q.save())
assert(x:is_persist())
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
-- q_meta shoud look something like 
-- local _09F76196A3A17BB5CF7CF6B1B9D2BBB6 = lVector ( { uqid = 1 } )
-- y =  _09F76196A3A17BB5CF7CF6B1B9D2BBB6
-- x =  _09F76196A3A17BB5CF7CF6B1B9D2BBB6
local mdir = lgutils.meta_dir()
assert(cutils.isdir(mdir))
mfile = mdir .. "/q_meta.lua"
assert(cutils.isfile(mfile))
local str = cutils.file_as_str(mfile)
-- Looking for y = 
local n1, n2 = string.find(str, "y = ")
assert(n1)
local n1, n2 = string.find(str, "y = ", n2)
assert(not n1)
-- Looking for x = 
local n1, n2 = string.find(str, "x = ")
assert(n1)
local n1, n2 = string.find(str, "x = ", n2)
assert(not n1)
-- Looking for lVector
local n1, n2 = string.find(str, "lVector %(")
assert(n1)
local n1, n2 = string.find(str,  "lVector %(", n2)
assert(not n1)



print("Completed test_save successfully")
