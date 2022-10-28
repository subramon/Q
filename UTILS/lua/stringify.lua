local ffi = require 'ffi'
local function stringify(str)
  assert(type(str) == "string")
  -- assert(#str > 0) OKAY TO HAVE NULL STRING 
  local len = #str + 1
  local cstr = assert(ffi.C.malloc(len))
  -- print("Allocating " .. tostring(len) .. " for " .. str)
  ffi.fill(cstr, len)
  if ( len > 1 ) then 
    ffi.copy(cstr, str, #str)
  end
  return ffi.cast("char *", cstr)
end
return stringify
