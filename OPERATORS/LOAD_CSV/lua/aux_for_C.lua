local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local function aux_for_C(M,
  l_file_offset, l_num_rows_read, l_is_load, l_has_nulls, 
  l_is_trim, l_width, l_c_qtypes
    )
  local file_offset   = get_ptr(l_file_offset,   "uint64_t *")
  local num_rows_read = get_ptr(l_num_rows_read, "uint64_t *")
  local is_load       = get_ptr(l_is_load,       "bool *")
  local has_nulls     = get_ptr(l_has_nulls,     "bool *")
  local is_trim       = get_ptr(l_is_trim,       "bool *")
  local width         = get_ptr(l_width,         "int *")
  local c_qtypes      = get_ptr(l_c_qtypes,      "int *")


  for i = 1, #M do
    is_load[i-1]   = M[i].is_load
    has_nulls[i-1] = M[i].has_nulls
    is_trim[i-1]   = false
    if ( M[i].qtype == "SC" ) then is_trim[i-1] = true end 
    width[i-1]     = M[i].width
    c_qtypes[i-1]  =  cutils.get_c_qtype(M[i].qtype)
  end
  file_offset[0] = 0

  return file_offset, num_rows_read, is_load, has_nulls, 
    is_trim, width, c_qtypes
end 
return aux_for_C
