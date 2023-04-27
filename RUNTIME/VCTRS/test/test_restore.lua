local plfile = require 'pl.file'
local plpath = require 'pl.path'
local plpretty = require 'pl.pretty'
require 'Q/UTILS/lua/strict'
-- copy config file to safe place
local q_root = os.getenv("Q_ROOT")
local orig_config_file = q_root .. "/config/q_config.lua"
assert(plpath.isfile(orig_config_file))
local save_config_file = "/tmp/q_config.lua"
plfile.copy(orig_config_file, save_config_file)
-- read old config, modify it and over-write usual config file 
local X = require 'q_config'
X.restore_session = true
local new_config_str = plpretty.write(X)
new_config_str = "local T = " .. new_config_str .. " return T "
plfile.write(orig_config_file, new_config_str)
--==============
os.sleep(60);


local lgutils = require 'liblgutils'
local Q = require 'Q'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'
local max_num_in_chunk = get_max_num_in_chunk()
local len = 2 * max_num_in_chunk + 3 
assert(type(x) == "lVector")
assert(x:qtype() == "I4")
local width = x:width()
assert(width == 4)
assert(x:num_elements() == len)
assert(lgutils.mem_used() == 0)
local expected = math.ceil(len/max_num_in_chunk)*max_num_in_chunk*width
assert(lgutils.dsk_used() == expected)
-- restore old config file 
plfile.copy(save_config_file, orig_config_file)
print("Completed test_restore")
