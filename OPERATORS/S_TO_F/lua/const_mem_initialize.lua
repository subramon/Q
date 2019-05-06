local ffi = require 'Q/UTILS/lua/q_ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function mem_initialize(subs)
  -- Set c_mem using info from args
  local c_mem = subs.val:to_cmem()
  local cst_as = subs.out_ctype .. " *"
  return c_mem, cst_as
end

return mem_initialize
