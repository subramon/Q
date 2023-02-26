local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local function malloc_aux(M)
  local nC = #M
  local cargs = { size = 1 * ffi.sizeof("uint64_t"), name = "l_file_offset", qtype = "I8", }
  local l_file_offset   = cmem.new(cargs)

  cargs.name = "l_num_rows_read"
  local l_num_rows_read = cmem.new(cargs)

  cargs = { size = nC * ffi.sizeof("bool"), name = "l_is_load", qtype = "BL", }
  local l_is_load       = cmem.new(cargs)

  cargs.name = "l_has_nulls"
  local l_has_nulls     = cmem.new(cargs)

  cargs.name = "l_is_trim"
  local l_is_trim       = cmem.new(cargs)

  local cargs = { size = nC * ffi.sizeof("int32_t"), name = "l_width", qtype = "I4", }
  local l_width         = cmem.new(cargs)

  cargs.name = "l_c_qtypes"
  local l_c_qtypes      = cmem.new(cargs)

  return l_file_offset, l_num_rows_read, l_is_load, l_has_nulls, 
    l_is_trim, l_width, l_c_qtypes
end 
return malloc_aux
