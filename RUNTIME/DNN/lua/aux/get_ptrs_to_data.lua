local ffi = require 'ffi'
local cmem		= require 'libcmem'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'

local function get_ptrs_to_data(lptrs, lX)
  assert(lptrs)
  assert(type(lX) == "table")
  local  cptrs = get_ptr(lptrs)
  cptrs = ffi.cast("float **", cptrs)
  for k, v in pairs(lX) do
    -- the end_write will occur when the vector is gc'd
    local x_len, x_chunk, nn_x_chunk = v:start_write()
    assert(x_chunk)
    assert(x_len > 0)
    assert(not nn_x_chunk)
    cptrs[k-1] = get_ptr(x_chunk, "F4") -- Note the -1 
  end
  return cptrs
end
--[[ TODO Do we need this function at all?
local function release_ptrs_to_data(lX)
  assert(lX and type(lX) == "table")
  for k, v in pairs(lX) do
    assert(v:end_write())
  end
  return true
end
--]]
return get_ptrs_to_data
--=====================================================
