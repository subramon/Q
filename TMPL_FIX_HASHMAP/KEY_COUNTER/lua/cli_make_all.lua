local plpath = require 'pl.path'
local make_all = require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/make_all'

assert(type(arg) == "table")
local config_file = assert(arg[1], "config file not provided")
assert(plpath.exists(config_file))
local x = loadfile(config_file)
assert(type(x) == "function")
local configs = x()
assert(type(configs) == "table")
cdef_str, so_file = make_all(configs)
