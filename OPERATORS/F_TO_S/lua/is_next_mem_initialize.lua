local ffi     = require 'Q/UTILS/lua/q_ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'

local function mem_initialize(subs)
  local rec_type = string.format("is_next_%s_%s_ARGS", subs.comparison, subs.qtype)
  if ( subs.fast ) then rec_type = "par_" .. rec_type end
  local hdr = string.format([[
    typedef struct _%s {
     %s prev_val;
      int is_violation;
      int num_seen;
    } %s
  ]], rec_type, subs.ctype, rec_type)
  pcall(ffi.cdef, hdr)

  -- Set c_mem using info from args
  local cst_as = rec_type .. " *"
  local sz_c_mem = ffi.sizeof(rec_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast(cst_as, get_ptr(c_mem))
  c_mem_ptr.prev_val     = 0
  c_mem_ptr.is_violation = 0
  c_mem_ptr.num_seen = 0

  --TODO: is it a right place for getter? check with Ramesh
  local getter = function (x)
    local y = ffi.cast(cst_as, get_ptr(c_mem))
    local is_good
    if ( y[0].is_violation == 1 ) then
      is_good = false
    else
      is_good = true
    end
    local n = y[0].num_seen
    return is_good, tonumber(n)
  end

  return c_mem, cst_as, getter
end

return mem_initialize
