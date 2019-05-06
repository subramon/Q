local Dictionary    = require 'Q/UTILS/lua/dictionary'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local lVector       = require 'Q/RUNTIME/lua/lVector'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local cmem          = require 'libcmem'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'

local function bridge_C(
  M, 
  infile, 
  fld_sep,
  is_hdr,
  file_offset,
  num_rows_read,
  data,
  nn_data
  )
  assert( M and type(M) == "table")
  assert(infile and type(infile) == "string")
  assert(is_hdr and type(is_hdr) == "boolean")
  assert(fld_sep and type(fld_sep) == "string")

  local nC = #M

  local is_load = get_ptr(cmem.new(nC * ffi.sizeof("bool")))
  is_load = ffi.cast("bool *", is_load)

  local has_nulls = get_ptr(cmem.new(nC * ffi.sizeof("bool")))
  has_nulls = ffi.cast("bool *", has_nulls)  
  
  local fld_name_width = 8 -- TODO Undo this hard coiding
  local fldtypes = ffi.cast("char **", 
    get_ptr(cmem.new(nC * ffi.sizeof("char *"))))
  for i = 1, nC do
    fldtypes[i-1]  = ffi.cast("char *", 
      get_ptr(cmem.new(fld_name_width * ffi.sizeof("char"))))
    ffi.copy(fldtypes[i-1], M[i].qtype)
    is_load[i-1]   = M[i].is_load
    has_nulls[i-1] = M[i].has_nulls
  end

  local status = qc["load_csv_fast"](infile, nC, fld_sep, 
    qconsts.chunk_size, num_rows_read, file_offset, fldtypes, is_hdr, 
    is_load, has_nulls, data, nn_data)
  assert(status == 0, "load_csv_fast failed")
  return true
end
return bridge_C
