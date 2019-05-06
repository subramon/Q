-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local ffi = require 'Q/UTILS/lua/q_ffi'
local qc = require 'Q/UTILS/lua/q_core'
local conv_lnum_to_cnum = require 'Q/UTILS/lua/conv_lnum_to_cnum'
local conv_cnum_to_lnum = require 'Q/UTILS/lua/conv_cnum_to_lnum'
--====================
local val = 123
local c_mem = conv_lnum_to_cnum(val, "I1")
local val2 = conv_cnum_to_lnum(c_mem, "I1")
assert(val2 == 123)
--====================

-- Commenting below section as location os foo.so is not known, also cnum_to_str symbol is not part of libq_core.so
--[[
ffi.cdef("int cnum_to_str( int64_t x, char *buf, int bufsz)")
--z = ffi.load("foo.so")
print("+++++++++++++++++++");
local val = 9223372036854775807LL
-- print(type(val)) == cdata
buf  = ffi.malloc(32)
alt_val = ffi.malloc(8)
alt_val = ffi.cast("int64_t *", alt_val)
alt_val[0] = val
print(alt_val[0])
alt_val[0] = 123456

local orig_ffi = require 'ffi'
qc.cnum_to_str(val, buf, 32)
print("output = ", orig_ffi.C.printf(stderr, "%s", buf))
]]
--====================
print( "Successfully completed " .. arg[0])

require('Q/UTILS/lua/cleanup')()
os.exit()
