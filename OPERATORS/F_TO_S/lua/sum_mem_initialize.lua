local ffi = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
local Scalar  = require 'libsclr'

local function mem_initialize(subs)
  local hdr = [[
    typedef struct _reduce_sum_<<qtype>>_args {
      <<reduce_ctype>> sum_val;
      uint64_t num; // number of non-null elements inspected
    } REDUCE_sum_<<qtype>>_ARGS;
  ]]

  hdr = string.gsub(hdr,"<<qtype>>", subs.qtype)
  hdr = string.gsub(hdr,"<<reduce_ctype>>",  subs.reduce_ctype)
  pcall(ffi.cdef, hdr)

  -- Set c_mem using info from args
  local rec_type = "REDUCE_sum_" .. subs.qtype .. "_ARGS"
  local cst_as = rec_type .. " *"
  local sz_c_mem = ffi.sizeof(rec_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast(cst_as, get_ptr(c_mem))
  c_mem_ptr.sum_val  = 0
  c_mem_ptr.num = 0

  --TODO: is it a right place for getter? check with Ramesh
  local getter = function (x)
    local y = ffi.cast(cst_as, get_ptr(c_mem))
    local z = ffi.cast("void *", y[0].num);
    -- TODO P2 I do not like the fact that I cannot send
    -- &(x[0].num) to Scalar.new for second Scalar call
    return Scalar.new(x, subs.reduce_qtype),
         Scalar.new(tonumber(y[0].num), "I8")
  end

  return c_mem, cst_as, getter
end

return mem_initialize
