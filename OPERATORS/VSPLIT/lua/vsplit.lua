local ffi           = require 'ffi'
local cutils        = require 'libcutils'
local lgutils       = require 'liblgutils'
local lVector       = require 'Q/RUNTIME/VCTRS/lua/lVector'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/validate_meta"
local get_ptr       = require 'Q/UTILS/lua/get_ptr'

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
  is_load, has_nulls, widths = foo(M)

  local opfiles, nn_opfiles = mk_op_files(M)
  for k, infile in ipairs(infiles) do
    vsplit(infile, #M, fld_sep, max_width, c_qtypes, is_hdr,
    is_load, has_nulls, widths, opfiles, nn_opfiles)
    print("Split ", k, infile)
  end
end
return require('Q/q_export').export('vsplit', vsplit)
