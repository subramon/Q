local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local qc      = require 'Q/UTILS/lua/qcore'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local record_time   = require 'Q/UTILS/lua/record_time'

local function bridge_C(
  M, 
  infile, 
  fld_sep,
  is_hdr,
  max_num_in_chunk,
  file_offset,
  num_rows_read,
  data,
  nn_data,
  is_load,
  has_nulls,
  is_trim,
  width,
  c_qtypes
  )
  assert( M and type(M) == "table")
  assert(infile and type(infile) == "string")
  assert(type(is_hdr) == "boolean")
  assert(fld_sep and type(fld_sep) == "string")

  local max_width = qcfg.max_width_SC
  local nC = #M

  for i = 1, nC do
    c_qtypes[i-1] =  cutils.get_c_qtype(M[i].qtype)
    is_trim[i-1] = false
    if ( M[i].qtype == "SC" ) then is_trim[i-1] = true end 
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

  local start_time = cutils.rdtsc()
  local status = qc[func_name](infile, nC, 
    ffi.cast("char *", fld_sep),
    max_num_in_chunk, max_width, num_rows_read, file_offset, c_qtypes, 
    is_trim, is_hdr, is_load, has_nulls, width, data, nn_data)
  assert(status == 0, "load_csv_fast failed")
  record_time(start_time, "load_csv_fast")
  return true
end
return bridge_C
