local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
local Scalar  = require 'libsclr'

local function mem_initialize(subs)
  local hdr = [[
    typedef struct _reduce_max_<<qtype>>_args {
      <<reduce_ctype>> max_val;
      uint64_t num; // number of non-null elements inspected
      int64_t max_index;
    } REDUCE_max_<<qtype>>_ARGS;
  ]]

  hdr = string.gsub(hdr,"<<qtype>>", subs.qtype)
  hdr = string.gsub(hdr,"<<reduce_ctype>>",  subs.reduce_ctype)
  pcall(ffi.cdef, hdr)

  -- Set c_mem using info from args
  local rec_type = "REDUCE_max_" .. subs.qtype .. "_ARGS"
  local cst_as = rec_type .. " *"
  local sz_c_mem = ffi.sizeof(rec_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = get_ptr(c_mem, cst_as)
  c_mem_ptr.max_val  = qconsts.qtypes[subs.qtype].min
  c_mem_ptr.num = 0
  c_mem_ptr.max_index = -1

  --TODO: is it a right place for getter? check with Ramesh
  local getter = function (x)
    local y = get_ptr(c_mem, cst_as)
    return Scalar.new(x, subs.reduce_qtype),
      Scalar.new(tonumber(y[0].num), "I8"), Scalar.new(tonumber(y[0].max_index), "I8")
  end

  return c_mem, cst_as, getter
end

return mem_initialize
