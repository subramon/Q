local libgen = require 'libgen'
local config = assert(arg[1])
local T      = require (config)
assert(type(T) == "table")
use_lua = false
libgen(T, use_lua)

