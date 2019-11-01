local libgen = require 'libgen'
local T1     = require 'test1'
assert(libgen(T1))
local T2     = require 'test2'
assert(libgen(T2))
print("All done")
