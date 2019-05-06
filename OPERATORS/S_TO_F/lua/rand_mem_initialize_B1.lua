local ffi = require 'Q/UTILS/lua/q_ffi'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function mem_initialize(subs)
  local hdr = [[
    typedef struct _rand_B1_rec_type {
      uint64_t seed;
      double probability;
    } RAND_B1_REC_TYPE;
  ]]

  pcall(ffi.cdef, hdr)

  -- Set c_mem using info from args
  local rec_type = "RAND_B1_REC_TYPE"
  local cst_as = rec_type .. " *"
  local sz_c_mem = ffi.sizeof(rec_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast(cst_as, get_ptr(c_mem))
  c_mem_ptr.seed = subs.seed
  c_mem_ptr.probability = subs.probability

  return c_mem, cst_as
end

return mem_initialize
