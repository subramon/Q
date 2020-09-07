local ffi = require 'ffi'
local function stringify(str)
  assert(type(str) == "string")
  assert(#str > 0)
  local len = #str + 1
  local cstr = assert(ffi.C.malloc(len))
  -- print("Allocating " .. tostring(len) .. " for " .. str)
  ffi.fill(cstr, len)
  ffi.copy(cstr, str, #str)
  return ffi.cast("char *", cstr)
end
return stringify
