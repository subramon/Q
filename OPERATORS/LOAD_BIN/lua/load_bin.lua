-- This version supports chunking in load_bin
local ffi           = require 'ffi'
local cutils        = require 'libcutils'
local cmem          = require 'libcmem'
local lgutils       = require 'liblgutils'
local lVector       = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local qc            = require 'Q/UTILS/lua/qcore'
local qcfg          = require 'Q/UTILS/lua/qcfg'
local get_max_num_in_chunk       = require 'Q/UTILS/lua/get_max_num_in_chunk'

 --======================================
local function load_bin(
  args,
  opt_args
  )
  -- START: Process args
  assert(type(args) == "table")
  local infile = assert(args.infile)
  local nnfile = args.nnfile
  local qtype = assert(args.qtype)
  local width = 0
  if ( qtype == "SC" ) then
    width = assert(args.width)
    assert(width >= 2)
    assert(width < qcfg.max_width_SC)
  else
    assert(type(args.width) == "nil")
    width = cutils.get_width_qtype(qtype)
    assert(width> 0)
  end
  --=======================================
  --== START Make C code 
  local subs = {}
  subs.fn = "load_data_from_file"
  subs.dotc = "OPERATORS/LOAD_BIN/src/load_data_from_file.c"
  subs.doth = "OPERATORS/LOAD_BIN/inc/load_data_from_file.h"
  subs.incs = { "OPERATORS/LOAD_BIN/inc/", "UTILS/inc/", }
  subs.srcs = { "UTILS/src/rs_mmap.c", }
  qc.q_add(subs); 
  --=======================================
  local vargs = {}
  vargs.qtype = qtype 
  vargs.width = width 
  vargs.max_num_in_chunk = get_max_num_in_chunk(optargs)
  assert(type(infile) == "string")
  assert(cutils.isfile(infile))
  local file_size = cutils.getsize(infile)
  local num_elements = math.floor(file_size / width)
  assert((num_elements * width ) == file_size) -- multiple of width

  local nn_file_size = 0
  if ( nnfile ) then 
    assert(type(nnfile) == "string")
    assert(nnfile ~= infile)
    assert(cutils.isfile(nnfile), "File not found " .. nnfile)
    vargs.has_nulls = true
    nn_file_size = cutils.getsize(nnfile)
    assert(nn_file_size == num_elements) -- using "BL" for nn
  else
    vargs.has_nulls = false
  end
  local name    = "load_bin"
  local nn_name = "nn_load_bin"
  if ( optargs ) and ( optargs.name ) then 
    assert(type(optargs.name) == "string")
    name    = optargs.name
    nn_name = "nn_" .. name
  end
  -- STOP : Process args
  -- Allocate buffers
  local l_chunk_num = 0
  local num_copied = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    local nn_buf
    local bufsz = vargs.max_num_in_chunk * vargs.width
    local buf = cmem.new(
      {size = bufsz, qtype = vargs.qtype, name = name})
    buf:zero()
    buf:stealable(true)
    if ( nnfile ) then 
      local nn_bufsz = vargs.max_num_in_chunk * 1 -- using "BL"
      nn_buf = cmem.new(
      {size = nn_bufsz, qtype = "BL", name = nn_name})
      nn_buf:zero()
      nn_buf:stealable(true)
    end
    local num_to_copy = num_elements - num_copied
    if ( num_to_copy > vargs.max_num_in_chunk ) then 
      num_to_copy = vargs.max_num_in_chunk
    end
    local bufptr = get_ptr(buf, "char *")
    local status = qc.load_data_from_file(infile, num_copied, 
      num_to_copy, width, bufptr)
    assert(status == 0)
    if ( nnfile ) then 
      local nn_bufptr = get_ptr(nn_buf, "char *")
      local status = qc.load_data_from_file(nnfile, num_copied, 
        num_to_copy, 1, nn_bufptr)
      assert(status == 0)
    end 
    num_copied = num_copied + num_to_copy
    l_chunk_num = l_chunk_num + 1 
    return num_to_copy, buf, nn_buf
  end
  vargs.gen = gen
  return lVector(vargs)
end
return require('Q/q_export').export('load_bin', load_bin)
