local ffi     = require 'ffi'
local function malloc_aux(nC) 
  local file_offset    = ffi.new("uint64_t[?]", 1)
  local num_rows_read = ffi.new("uint64_t[?]", 1)
  local is_load       = ffi.new("bool[?]", nC)
  local has_nulls     = ffi.new("bool[?]", nC)
  local is_trim       = ffi.new("bool[?]", nC)
  local width         = ffi.new("int[?]", nC)
  local c_qtypes      = ffi.new("int[?]", nC)

  return file_offset, num_rows_read, is_load, has_nulls, is_trim, 
    width, c_qtypes
end 
return malloc_aux
