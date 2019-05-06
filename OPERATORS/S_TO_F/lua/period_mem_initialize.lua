local ffi = require 'Q/UTILS/lua/q_ffi'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function mem_initialize(subs)
  local hdr = [[
    typedef struct _period_<<qtype>>_rec_type {
      <<ctype>> start;
      <<ctype>> by;
     int period;
    } PERIOD_<<qtype>>_REC_TYPE;
  ]]

  hdr = string.gsub(hdr,"<<qtype>>", subs.out_qtype)
  hdr = string.gsub(hdr,"<<ctype>>",  subs.out_ctype)
  pcall(ffi.cdef, hdr)

  -- Set c_mem using info from args
  local rec_type = 'PERIOD_' .. subs.out_qtype .. '_REC_TYPE'
  local cst_as = rec_type .. " *"
  local sz_c_mem = ffi.sizeof(rec_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast(cst_as, get_ptr(c_mem))
  c_mem_ptr.start = subs.start:to_num()
  c_mem_ptr.by = subs.by:to_num()
  c_mem_ptr.period = subs.period:to_num()

  return c_mem, cst_as
end

return mem_initialize
