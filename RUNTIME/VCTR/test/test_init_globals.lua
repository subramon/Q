require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
--== cdef necessary stuff
local for_cdef = require 'Q/UTILS/lua/for_cdef'

local infile = "RUNTIME/CMEM/inc/cmem_struct.h"
local incs = { "UTILS/inc/" }
local x = for_cdef(infile, incs)
ffi.cdef(x)

local infile = "RUNTIME/VCTR/inc/core_vec_struct.h"
local incs = { "UTILS/inc/" }
local x = for_cdef(infile, incs)
ffi.cdef(x)
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

