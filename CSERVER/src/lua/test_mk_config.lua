
local ffi = require 'ffi'
local mk_config = require 'Q/CSERVER/src/lua/mk_config'
local q_consts  = require 'Q/UTILS/lua/q_consts'
require  'Q/CSERVER/src/lua/to_cdef'


local sz = ffi.sizeof("config_t")
C = ffi.C.malloc(sz)
ffi.fill(C, sz)
mk_config(C)
C = ffi.cast("config_t *", C)
print(C[0].port)
print(ffi.string(C[0].qc_flags))
print("All done")
