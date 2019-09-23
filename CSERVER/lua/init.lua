-- local Q = require 'Q'

ffi  = require 'ffi'
ffi.cdef([[
extern int
add_I4_I4_I4(
    int *X,
    int *Y,
    int n,
    int *Z
    );
    ]]
)

qc = ffi.load('../c_engine/libq_core.so')

print "Initialized Lua state"
-- dummy = require 'dummy'
return true
