local ffi           = require 'ffi'
local cutils        = require 'libcutils'
local lgutils       = require 'liblgutils'
local qc            = require 'Q/UTILS/lua/qcore'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/validate_meta"
local malloc_aux    = require "Q/OPERATORS/LOAD_CSV/lua/malloc_aux"
local aux_for_C     = require "Q/OPERATORS/LOAD_CSV/lua/aux_for_C"
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local tbl_of_str_to_C_array = require 'Q/UTILS/lua/tbl_of_str_to_C_array'

local function mk_op_files(M, opdir)
  local opfiles = {}
  local nn_opfiles = {}
  for k, v in ipairs(M) do 
    opfiles[k] = ""
    nn_opfiles[k] = ""
    if ( v.is_load) then 
      opfiles[k] = "_" .. v.name
      assert(cutils.mk_file(opdir, opfiles[k], 0, true))
      if ( v.has_nulls ) then 
        nn_opfiles[k] = "_" .. v.name
        assert(cutils.mk_file(opdir, nn_opfiles[k], 0, true))
      end
    end
  end
  local c_opfiles = tbl_of_str_to_C_array(opfiles)
  local c_nn_opfiles = tbl_of_str_to_C_array(nn_opfiles)
  return c_opfiles, c_nn_opfiles
end
--=============================================
local function process_optargs(optargs)
  local fld_sep = ","
  local is_hdr = false
  if ( optargs ) then
    error("TODO")
    assert(type(optargs) == "table")
    if ( type(optargs.is_hdr) ~= "nil" ) then
      assert(type(optargs.is_hdr) == "boolean")
      is_hdr = optargs.is_hdr
    end
    if ( type(optargs.fld_sep) ~= "nil" ) then
      assert(type(optargs.fld_sep) == "string")
      fld_sep = optargs.fld_se
    end
  end
  return is_hdr, fld_sep
end
 --======================================
local function vsplit(
  infiles,   -- table of input file to read (string)
  M,  -- metadata (table)
  opdir, -- output directory 
  opt_args
  )
  assert( type(infiles) == "table")
  assert(#infiles > 0)
  for k, infile in ipairs(infiles) do 
    assert(type(infile) == "string")
    assert(cutils.isfile(infile))
    assert(tonumber(cutils.getsize(infile)) > 0)
  end

  assert( type(opdir) == "string")
  assert(cutils.isdir(opdir))

  local is_hdr, fld_sep = process_optargs(optargs)
  local max_width = 1024 -- TODO THINK 
  assert(validate_meta(M))
  --=======================================
  local l_file_offset, l_num_rows_read, l_is_load, l_has_nulls, 
    l_is_trim, l_width, l_c_qtypes = 
    malloc_aux(M)
  local file_offset, num_rows_read, is_load, has_nulls, 
    is_trim, width, c_qtypes = 
    aux_for_C(M, l_file_offset, l_num_rows_read, l_is_load, l_has_nulls, 
    l_is_trim, l_width, l_c_qtypes)
  --=======================================

  local opfiles, nn_opfiles = mk_op_files(M, opdir)

  --== START Make C code 
  local subs = {}
  subs.fn = "vsplit"
  subs.dotc = "OPERATORS/VSPLIT/src/vsplit.c"
  subs.doth = "OPERATORS/VSPLIT/inc/vsplit.h"
  subs.incs = { "OPERATORS/LOAD_CSV/inc/", 
    "OPERATORS/VSPLIT/inc/", 
    "UTILS/inc/", }
  subs.srcs = { "UTILS/src/is_valid_chars_for_num.c", 
    "OPERATORS/LOAD_CSV/src/get_cell.c",
    "OPERATORS/LOAD_CSV/src/asc_to_bin.c",
    "OPERATORS/LOAD_CSV/src/get_fld_sep.c",
    "UTILS/src/rs_mmap.c",  
    "UTILS/src/set_bit_u64.c",  
    "UTILS/src/trim.c",  
    "UTILS/src/txt_to_I1.c", 
    "UTILS/src/txt_to_I2.c", 
    "UTILS/src/txt_to_I4.c", 
    "UTILS/src/txt_to_I8.c", 
    "UTILS/src/txt_to_UI1.c", 
    "UTILS/src/txt_to_UI2.c", 
    "UTILS/src/txt_to_UI4.c", 
    "UTILS/src/txt_to_UI8.c", 
    "UTILS/src/txt_to_F4.c", 
    "UTILS/src/txt_to_F8.c", 
}
  qc.q_add(subs); 
  --== STOP  Make C code 
  for k, infile in ipairs(infiles) do
    qc.vsplit(infile, #M, fld_sep, max_width, l_c_qtypes, 
    is_load, has_nulls, width, opfiles, nn_opfiles)
    print("Split ", k, infile)
  end
  l_file_offset:delete()
  l_num_rows_read:delete()
  l_is_load:delete()
  l_has_nulls:delete()
  l_is_trim:delete()
  l_width:delete()
  l_c_qtypes:delete()
end
return require('Q/q_export').export('vsplit', vsplit)
