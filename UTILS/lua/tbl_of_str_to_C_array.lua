local ffi = require 'ffi'
local function tbl_of_str_to_C_array(J)
  assert(type(J) == "table")
  local T = ffi.new("char *[?]", #J)
  T = ffi.cast("char **", T)
  local n = 0
  for i, sval in ipairs(J) do 
    assert(type(sval) == "string")
    T[i-1] = ffi.new("char[?]", #sval+1)
    ffi.copy(T[i-1], sval)
    n = n + 1
  end
  assert(n ~= 0)
  T = ffi.cast("const char ** const", T)
  return T, n
end
return tbl_of_str_to_C_array
