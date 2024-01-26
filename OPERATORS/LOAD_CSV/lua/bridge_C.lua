local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local cVector = require 'libvctr'
local qc      = require 'Q/UTILS/lua/qcore'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local record_time   = require 'Q/UTILS/lua/record_time'

local function bridge_C(
  M, 
  infile, 
  fld_sep,
  is_hdr,
  is_par,
  max_num_in_chunk,
  file_offset,
  num_rows_read,
  c_data,
  nn_c_data,
  is_load,
  has_nulls,
  is_trim,
  width,
  c_qtypes,
  c_nn_qtype
  )
  assert( M and type(M) == "table")
  assert(type(infile) == "string")
  assert(type(is_hdr) == "boolean")
  assert(type(fld_sep) == "string")

  local max_width = qcfg.max_width_SC
  local nC = #M
  local subs = {}
  if ( is_par ) then 
    subs.fn = "load_csv_par"
    subs.dotc = "OPERATORS/LOAD_CSV/src/load_csv_par.c"
    subs.doth = "OPERATORS/LOAD_CSV/inc/load_csv_par.h"
  else
    subs.fn = "load_csv_seq"
    subs.dotc = "OPERATORS/LOAD_CSV/src/load_csv_seq.c"
    subs.doth = "OPERATORS/LOAD_CSV/inc/load_csv_seq.h"
  end 
  subs.incs = { "OPERATORS/LOAD_CSV/inc/", "UTILS/inc/" }
  subs.srcs = { "UTILS/src/is_valid_chars_for_num.c", 
    "OPERATORS/LOAD_CSV/src/get_cell.c",
    "OPERATORS/LOAD_CSV/src/asc_to_bin.c",
    "OPERATORS/LOAD_CSV/src/get_fld_sep.c",
    "OPERATORS/LOAD_CSV/src/chk_data.c",
    "UTILS/src/get_bit_u64.c",  
    "UTILS/src/set_bit_u64.c",  
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
  -- print("About to call ", func_name)
  local status = qc[func_name](infile, nC, fld_sep, max_num_in_chunk, max_width, num_rows_read, file_offset, c_qtypes, c_nn_qtype, is_trim, is_hdr,
  is_load, has_nulls, width, c_data, nn_c_data)
  local l_file_offset = tonumber(file_offset[0])
  -- print("C: l_file_offset = ", l_file_offset)
  assert(status == 0)
  record_time(start_time, "load_csv")
  return true
end
return bridge_C
