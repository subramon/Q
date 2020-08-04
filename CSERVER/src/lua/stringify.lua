local ffi = require 'ffi'
local function stringify(str)
  assert(type(str) == "string")
  assert(#str > 0)
  local len = #str + 1
  local cstr = assert(ffi.C.malloc(len))
  ffi.fill(cstr, len)
  ffi.copy(cstr, str, len-1)
  return ffi.cast("char *", cstr)
end
return stringify
