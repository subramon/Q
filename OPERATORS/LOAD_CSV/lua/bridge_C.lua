local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'

local function bridge_C(
  M, 
  infile, 
  fld_sep,
  is_hdr,
  chunk_size,
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
  assert(type(is_hdr) == "boolean")
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
    is_load[i-1]   = M[i].is_load
    has_nulls[i-1] = M[i].has_nulls
    width[i-1]     = M[i].width
  end
  local subs = {}
  subs.fn = "load_csv_fast"
  subs.dotc = "OPERATORS/LOAD_CSV/src/load_csv_fast.c"
  subs.doth = "OPERATORS/LOAD_CSV/inc/load_csv_fast.h"
  subs.incs = { "OPERATORS/LOAD_CSV/inc/", "UTILS/inc/" }
  subs.srcs = { "UTILS/src/is_valid_chars_for_num.c", 
    "UTILS/src/get_bit_u64.c",  
    "UTILS/src/rs_mmap.c",  
    "UTILS/src/trim.c",  
    "UTILS/src/txt_to_I1.c", 
    "UTILS/src/txt_to_I2.c", 
    "UTILS/src/txt_to_I4.c", 
    "UTILS/src/txt_to_I8.c", 
    "UTILS/src/txt_to_F4.c", 
    "UTILS/src/txt_to_F8.c", 
}
  qc.q_add(subs); 
  local func_name = subs.fn

  local status = qc[func_name](infile, nC, 
    ffi.cast("char *", fld_sep),
    chunk_size, num_rows_read, file_offset, fldtypes, 
    is_trim, is_hdr, is_load, has_nulls, width, data, nn_data)
  assert(status == 0, "load_csv_fast failed")
  return true
end
return bridge_C
