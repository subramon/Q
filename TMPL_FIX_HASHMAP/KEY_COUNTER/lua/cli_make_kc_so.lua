local plpath = require 'pl.path'
local make_kc_so = require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/make_kc_so'

assert(type(arg) == "table")
local config_file = assert(arg[1], "config file not provided")
assert(plpath.exists(config_file))
local x = loadfile(config_file)
assert(type(x) == "function")
local configs = x()
assert(type(configs) == "table")
so_file, cdef_str = make_kc_so(configs)
print("All done")
