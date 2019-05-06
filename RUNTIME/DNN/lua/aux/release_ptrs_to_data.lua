local ffi		= require 'Q/UTILS/lua/q_ffi'
local cmem		= require 'libcmem'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'

local function release_ptrs_to_data(lX)
  assert(lX and type(lX) == "table")
  for k, v in pairs(lX) do
    assert(v:end_write())
  end
  return true
end

return release_ptrs_to_data
--======================================================
