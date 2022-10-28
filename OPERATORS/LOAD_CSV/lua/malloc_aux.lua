local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local function malloc_aux(M)
  local nC = #M
  local l_file_offset   = cmem.new( 1 * ffi.sizeof("uint64_t"))
  l_file_offset:set_name("l_file_offset"); -- for debugging 

  local l_num_rows_read = cmem.new( 1 * ffi.sizeof("uint64_t"))
  l_num_rows_read:set_name("l_num_rows_read"); -- for debugging 

  local l_is_load       = cmem.new(nC * ffi.sizeof("bool"))
  l_is_load:set_name("l_is_load") -- for debugging 

  local l_has_nulls     = cmem.new(nC * ffi.sizeof("bool"))
  l_has_nulls:set_name("l_has_nulls") -- for debugging 

  local l_is_trim       = cmem.new(nC * ffi.sizeof("bool"))
  l_is_trim:set_name("l_is_trim") -- for debugging 

  local l_width         = cmem.new(nC * ffi.sizeof("uint32_t"))
  l_width:set_name("l_width") -- for debugging 

  local l_c_qtypes      = cmem.new(nC * ffi.sizeof("int"))
  l_c_qtypes:set_name("l_c_qtypes") -- for debugging 

  return l_file_offset, l_num_rows_read, l_is_load, l_has_nulls, 
    l_is_trim, l_width, l_c_qtypes
end 
return malloc_aux
