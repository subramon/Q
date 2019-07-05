local ffi           = require 'Q/UTILS/lua/q_ffi'
local get_ptr	    = require 'Q/UTILS/lua/get_ptr'
local cmem          = require 'libcmem'

local cmem_file_offset
local num_rows_read
local is_load
local has_nulls
local is_trim
local width
local fldtypes

local F = {}
F.malloc_aux = function (nC)
  print("Malloc'ing auxiliary structures for load csv ")
  cmem_file_offset = cmem.new(1*ffi.sizeof("uint64_t"))
  local file_offset = ffi.cast("uint64_t *", get_ptr(cmem_file_offset))
  file_offset[0] = 0

  cmem_num_rows_read = cmem.new(1*ffi.sizeof("uint64_t"))
  local num_rows_read = ffi.cast("uint64_t *", get_ptr(cmem_num_rows_read))

  cmem_is_load = cmem.new(nC * ffi.sizeof("bool"))
  local is_load = ffi.cast("bool *", get_ptr(cmem_is_load))

  cmem_has_nulls = cmem.new(nC * ffi.sizeof("bool"))
  local has_nulls = ffi.cast("bool *", get_ptr(cmem_has_nulls))
  
  cmem_is_trim = cmem.new(nC * ffi.sizeof("bool"))
  local is_trim = ffi.cast("bool *", get_ptr(cmem_is_trim))
  
  cmem_width = cmem.new(nC * ffi.sizeof("int"))
  local width = ffi.cast("int *", get_ptr(cmem_width))
  
  cmem_fldtypes = cmem.new(nC * ffi.sizeof("int"))
  local fldtypes = ffi.cast("int *", get_ptr(cmem_fldtypes))

  return file_offset, num_rows_read, is_load, has_nulls, is_trim, 
    width, fldtypes 
end 
F.free_aux =  function ()
  print("Freeing auxiliary structures for load csv ")
  cmem_num_rows_read:delete()
  cmem_is_load:delete()
  cmem_has_nulls:delete()
  cmem_is_trim:delete()
  cmem_width:delete()
  cmem_fldtypes:delete()
end

return F
