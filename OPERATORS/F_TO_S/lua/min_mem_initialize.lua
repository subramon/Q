local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
local Scalar  = require 'libsclr'

local function mem_initialize(subs)
  local hdr = [[
    typedef struct _reduce_min_<<qtype>>_args {
      <<reduce_ctype>> min_val;
      uint64_t num; // number of non-null elements inspected
      int64_t min_index;
    } REDUCE_min_<<qtype>>_ARGS;
  ]]

  hdr = string.gsub(hdr,"<<qtype>>", subs.qtype)
  hdr = string.gsub(hdr,"<<reduce_ctype>>",  subs.reduce_ctype)
  pcall(ffi.cdef, hdr)

  -- Set c_mem using info from args
  local rec_type = "REDUCE_min_" .. subs.qtype .. "_ARGS"
  local cst_as = rec_type .. " *"
  local sz_c_mem = ffi.sizeof(rec_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast(cst_as, get_ptr(c_mem))
  c_mem_ptr.min_val  = qconsts.qtypes[subs.qtype].max
  c_mem_ptr.num = 0
  c_mem_ptr.min_index = -1

  --TODO: is it a right place for getter? check with Ramesh
  local getter = function (x)
    local y = ffi.cast(cst_as, get_ptr(c_mem))
    return Scalar.new(x, subs.reduce_qtype),
      Scalar.new(tonumber(y[0].num), "I8"), Scalar.new(tonumber(y[0].min_index), "I8")
  end

  return c_mem, cst_as, getter
end

return mem_initialize
