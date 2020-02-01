require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local get_func_decl = require 'Q/UTILS/build/get_func_decl'

local hdrs = get_func_decl("../inc/core_vec_struct.h", " -I../../../UTILS/inc/")
pcall(ffi.cdef, hdrs)
-- following only because we are testing. Normally, we get this from q_core
local hdrs = get_func_decl("../../CMEM/inc/cmem_struct.h", " -I../../../UTILS/inc/")
pcall(ffi.cdef, hdrs)
--=================================
local tests = {}
tests.t1 = function ()
local params = { chunk_size = 65536, sz_chunk_dir = 1024, 
  data_dir = qconsts.Q_DATA_DIR }
cVector.init_globals(params)
print(">>>> START:  Deliberate error")
local status = cVector.init_globals(params)
assert(not status)
print("<<<< STOP:  Deliberate error")

print("Successfully completed test t1")
end
return tests
-- tests.t1()
-- os.exit()
