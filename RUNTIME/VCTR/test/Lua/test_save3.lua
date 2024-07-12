local pldir = require 'pl.dir'
require 'Q/UTILS/lua/strict'
local lgutils = require 'liblgutils'
local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local is_in   = require 'RSUTILS/lua/is_in'

local max_num_in_chunk = qcfg.max_num_in_chunk 
local len = 2 * max_num_in_chunk + 3 

x = Q.const({ val = 1, qtype = "I4", len = len}):set_name("x"):eval()
x:chunks_to_lma()
x:drop_mem(2) 
assert(Q.save())
local ddir = lgutils.data_dir()
local data_files = pldir.getfiles(ddir)
local exp_files = {
"/home/subramon/local/Q/data/_100000_FFFFFF", -- this is the lma file 
}

assert(#data_files == #exp_files)
for k1, v1 in pairs(data_files) do 
  assert(is_in(v1, exp_files))
end
print("Completed test_save2")
