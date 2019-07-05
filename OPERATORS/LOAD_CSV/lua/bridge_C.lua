local Dictionary    = require 'Q/UTILS/lua/dictionary'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local lVector       = require 'Q/RUNTIME/lua/lVector'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'

local function bridge_C(
  M, 
  infile, 
  fld_sep,
  is_hdr,
  file_offset,
  num_rows_read,
  data,
  nn_data,
  is_load,
  has_nulls,
  is_trim,
  width,
  fldtypes
  )
  assert( M and type(M) == "table")
  assert(infile and type(infile) == "string")
  assert(is_hdr and type(is_hdr) == "boolean")
  assert(fld_sep and type(fld_sep) == "string")

  local nC = #M

  -- this is ugly as sin but might keep us out of memory troubles
  for i = 1, nC do
    fldtypes[i-1] =  0
    if ( M[i].qtype == "B1" ) then 
      fldtypes[i-1] = 1; is_trim[i-1] = true
    elseif ( M[i].qtype == "I1" ) then 
      fldtypes[i-1] = 2; is_trim[i-1] = true
    elseif ( M[i].qtype == "I2" ) then 
      fldtypes[i-1] = 3; is_trim[i-1] = true
    elseif ( M[i].qtype == "I4" ) then 
      fldtypes[i-1] = 4; is_trim[i-1] = true
    elseif ( M[i].qtype == "I8" ) then 
      fldtypes[i-1] = 5; is_trim[i-1] = true
    elseif ( M[i].qtype == "F4" ) then 
      fldtypes[i-1] = 6; is_trim[i-1] = true
    elseif ( M[i].qtype == "F8" ) then 
      fldtypes[i-1] = 7; is_trim[i-1] = true
    elseif ( M[i].qtype == "SC" ) then 
      fldtypes[i-1] = 8; is_trim[i-1] = false
    else 
      assert(nil)
    end
  end
  for i = 1, nC do
    is_load[i-1] = M[i].is_load
    has_nulls[i-1] = M[i].has_nulls
    width[i-1] = M[i].width
  end

  local status = qc["new_load_csv_fast"](infile, nC, 
    ffi.cast("char *", fld_sep),
    qconsts.chunk_size, num_rows_read, file_offset, fldtypes, 
    is_trim, is_hdr, is_load, has_nulls, width, data, nn_data)
  assert(status == 0, "load_csv_fast failed")
  return true
end
return bridge_C
