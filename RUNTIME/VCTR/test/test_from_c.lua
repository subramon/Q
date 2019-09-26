local ffi     = require 'ffi'
local lVector = require 'libvctr'
local Scalar  = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local clean_defs = require 'Q/RUNTIME/VCTR/test/clean_defs'

hdrs = clean_defs("../inc/core_vec_struct.h", " -I../../../UTILS/inc/")
ffi.cdef(hdrs)

local qtype = "F4"
local width = qconsts.qtypes[qtype].width
local v = lVector.new(qtype, width);
assert( not  v:get1(0))
assert( not  v:get1(-1))
assert( not  v:get1(1))
local M = assert(v:me())
M = ffi.cast("VEC_REC_TYPE *", M)
assert(M[0].num_elements == 0)

for i = 1, 1000000 do 
  local s = Scalar.new(i, "F4")
  v:put1(s)
  local M = assert(v:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  assert(M[0].num_elements == i, "failed at " .. i)
end
-- lVector:print_timers()
lVector:reset_timers()
print("All done")
