local ffi = require 'Q/UTILS/lua/q_ffi'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function mem_initialize(subs)
  if subs.out_qtype == "B1" then
    local mem_initialize = require 'Q/OPERATORS/S_TO_F/lua/rand_mem_initialize_B1'
    local status, c_mem_B1, cst_as = pcall(mem_initialize, subs)
    if status then
      return c_mem_B1, cst_as
    else
      print(c_mem_B1)
      return nil
    end
  end

  local hdr = [[
    typedef struct _rand_<<qtype>>_rec_type {
      uint64_t seed;
      <<ctype>> lb;
      <<ctype>> ub;
      struct drand48_data buffer;
    } RAND_<<qtype>>_REC_TYPE;
  ]]
  hdr = string.gsub(hdr,"<<qtype>>", subs.out_qtype)
  hdr = string.gsub(hdr,"<<ctype>>",  subs.out_ctype)
  pcall(ffi.cdef, hdr)

  -- Set c_mem using info from args
  local rec_type = "RAND_" .. subs.out_qtype .. "_REC_TYPE"
  local cst_as = rec_type .. " *"
  local sz_c_mem = ffi.sizeof(rec_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast(cst_as, get_ptr(c_mem))
  c_mem_ptr.lb = subs.lb:to_num()
  c_mem_ptr.ub = subs.ub:to_num()
  c_mem_ptr.seed = subs.seed

  return c_mem, cst_as
end

return mem_initialize
