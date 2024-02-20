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
  assert(type(args.qtype) == "string")
  --=======================================
  local vargs = {}
  local qtype = assert(args.qtype)
  local width = 0
  if ( qtype == "SC" ) then
    width = assert(args.width)
    assert(width >= 2)
    assert(width < qcfg.max_width_SC)
    vargs.width = width
  else
    assert(type(args.width) == "nil")
    width = cutils.get_width_qtype(qtype)
    assert(width> 0)
  end
  --=======================================
  -- Check infiles 
  local infiles = assert(args.infiles)
  assert(type(infiles) == "table")
  local num_in_files = {}
  for k, infile in ipairs(infiles) do 
    assert(type(infile) == "string")
    assert(cutils.isfile(infile))
    local file_size = cutils.getsize(infile)
    local num_in_file = math.floor(file_size / width)
    assert((num_in_file * width ) == file_size) -- multiple of width
    num_in_files[k] = num_in_file
  end

  -- Check nnfiles if necessary
  local nnfiles = args.nnfiles
  if ( nnfiles ) then 
    assert(type(nnfiles) == "table")
    assert(#nnfiles == #infiles)
    for k, nnfile in ipairs(nnfiles) do 
      assert(type(nnfile) == "string")
      assert(cutils.isfile(nnfile))
      assert(nnfile ~= infile)
      assert(cutils.isfile(nnfile), "File not found " .. nnfile)
      nn_file_size = cutils.getsize(nnfile)
      assert(nn_file_size == num_in_files[k]) -- using "BL" for nn
    end
  end

  --== START Make C code 
  local subs = {}
  subs.fn = "load_data_from_file"
  subs.dotc = "OPERATORS/LOAD_BIN/src/load_data_from_file.c"
  subs.doth = "OPERATORS/LOAD_BIN/inc/load_data_from_file.h"
  subs.incs = { "OPERATORS/LOAD_BIN/inc/", "UTILS/inc/", }
  subs.srcs = { "UTILS/src/rs_mmap.c", }
  qc.q_add(subs); 
  --=======================================
  vargs.qtype = qtype 
  vargs.width = width 
  vargs.max_num_in_chunk = get_max_num_in_chunk(optargs)
  if ( nnfiles ) then 
    vargs.has_nulls = true
  else
    vargs.has_nulls = false
  end
  vargs.name    = "load_bin"
  if ( optargs ) and ( optargs.name ) then 
    assert(type(optargs.name) == "string")
    vargs.name    = optargs.name
  end

  -- STOP : Process args
  local l_chunk_num = 0
  -- how many files have we *finished* processing
  local num_files_processed = 0
  -- file_offset is in number of elements, not bytes
  -- need to multiply by width for bytes
  local file_offset = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    -- Allocate buffers
    local nn_buf
    local bufsz = vargs.max_num_in_chunk * width
    local buf = cmem.new( {size = bufsz, qtype = vargs.qtype})
    buf:zero()
    buf:stealable(true)
    if ( nnfiles ) then 
      local nn_bufsz = vargs.max_num_in_chunk * 1 -- using "BL"
      nn_buf = cmem.new( {size = nn_bufsz, qtype = "BL", })
      nn_buf:zero()
      nn_buf:stealable(true)
    end
    -- how many elements have we placed in buf
    local num_copied = 0
    --===================================================
    while ( ( num_files_processed < #infiles ) and 
            ( num_copied < vargs.max_num_in_chunk ) ) do
      -- how many elements from current file to be copied
      local num_in_file = num_in_files[num_files_processed+1] - file_offset
      print("num_in_file = ", num_in_file )
      if ( num_in_file == 0 ) then
        num_files_processed = num_files_processed + 1 
        print("num_files_processed = ", num_files_processed)
        -- if no more files to process, break out of while loop 
        if ( num_files_processed >= #infiles ) then break end 
        file_offset = 0
        num_in_file = num_in_files[num_files_processed+1] - file_offset
      end
      assert(num_in_file > 0)
      -- how much space do we have in buffer
      local space_in_buf = vargs.max_num_in_chunk - num_copied
      if ( num_in_file > space_in_buf ) then 
        num_to_copy = space_in_buf
      else
        num_to_copy = num_in_file
      end
      print(num_in_file, space_in_buf, num_to_copy)
      local bufptr = get_ptr(buf, "char *")
      local infile = infiles[num_files_processed+1]
      assert(type(infile) == "string")
      assert(#infile > 0)
      print("Loading " .. num_to_copy .. " from " .. infile)
      local status = qc.load_data_from_file(infile, file_offset, 
        num_to_copy, width, bufptr)
      assert(status == 0)
      if ( nnfiles ) then 
        local nn_bufptr = get_ptr(nn_buf, "char *")
        local nnfile = nnfiles[num_files_processed+1]
        local status = qc.load_data_from_file(nnfile, file_offset,
          num_to_copy, 1, nn_bufptr)
        assert(status == 0)
      end 
      num_copied = num_copied + num_to_copy
      file_offset = file_offset + num_to_copy
    end
    l_chunk_num = l_chunk_num + 1 
    return num_copied, buf, nn_buf
  end
  vargs.gen = gen
  return lVector(vargs):set_name(vargs.name)
end
return require('Q/q_export').export('load_bin', load_bin)
