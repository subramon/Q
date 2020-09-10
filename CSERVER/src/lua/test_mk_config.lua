local ffi = require 'ffi'
local mk_config = require 'Q/CSERVER/src/lua/mk_config'
local qconsts = require 'Q/UTILS/lua/qconsts'
require  'Q/CSERVER/src/lua/to_cdef'


local sz = ffi.sizeof("q_server_t")
S = ffi.C.malloc(sz)
ffi.fill(S, sz)
mk_config(S)
S = ffi.cast("q_server_t *", S)
print("port       = ", S[0].port)
print("sz_body    = ", S[0].sz_body)
print("sz_rslt    = ", S[0].sz_rslt)
print("chunk_size = ", S[0].chunk_size)
print("qc_flags   = ", ffi.string(S[0].qc_flags))
print("q_data_dir = ", ffi.string(S[0].q_data_dir))
print("q_root     = ", ffi.string(S[0].q_root))
print("q_src_root = ", ffi.string(S[0].q_src_root))
print("All done")
