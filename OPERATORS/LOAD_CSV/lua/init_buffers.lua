local data_dir      = require('Q/q_export').Q_DATA_DIR
local Dictionary    = require 'Q/UTILS/lua/dictionary'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local lVector       = require 'Q/RUNTIME/lua/lVector'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local cmem          = require 'libcmem'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'

local function get_binary_width(field)
  local w
  if field.qtype == "SC" then
    w = assert(field.width)
  else
    w = assert(qconsts.qtypes[field.qtype].width)
  end
  return w
end

local function init_buffers(M)
  assert(type(M) == "table")
  local num_cols = #M
  assert(num_cols > 0)
  local cols = {} -- cols[i] is Column used for column i
  local dicts = {} -- dicts[i] is di ctionary used for column i
  local out_bufs = {}
  local nn_out_bufs = {}
  -- Each column to be loaded is allocated a buffer so that we 
  -- do not have to call lVector:put_chunk() for every element
  -- In this loop we decide on n_buf, the number of elements in the buffer
  local n_buf = qconsts.chunk_size
  local row_width = 0 -- bytes to store one row
  for col_idx = 1, num_cols do
    if M[col_idx].is_load then
      row_width = row_width + get_binary_width(M[col_idx])
    end
  end
  assert(row_width >  0)
  while ( n_buf * row_width > qconsts.space_for_load_csv ) do 
    if ( n_buf <= 1024 ) then break end 
    n_buf = n_buf / 2  
  end
  -- following necessary for nn_vec allocation
  assert( math.ceil(n_buf / 8 )  == math.floor(n_buf / 8 ) )
      
  -- This loop does following things
  -- (2) create lvector for each is_load column
  -- (3) create Dictionary for each is_load SV column
  -- (4) create output buffer for each is_load column
  for col_idx = 1, num_cols do
    if M[col_idx].is_load then
      local binary_width = get_binary_width(M[col_idx])
      local lvec_args = { qtype=M[col_idx].qtype, gen = true,
        is_memo=true, has_nulls=M[col_idx].has_nulls}
      if ( M[col_idx].qtype == "SC" ) then 
        lvec_args.width=binary_width
      end
      cols[col_idx] = lVector(lvec_args)
      M[col_idx].num_nulls = 0
      if M[col_idx].qtype == "SV" then
        dicts[col_idx] = assert(Dictionary(M[col_idx].dict),
        "error creating dictionary " .. M[col_idx].dict .. " for " .. M[col_idx].name)
        cols[col_idx]:set_meta("dir", dicts[col_idx])
      end
      if ( M[col_idx].meaning ~= nil ) then
        assert(type(M[col_idx].meaning) == "string", "type of meaning field is not string")
        cols[col_idx]:set_meta("meaning", M[col_idx].meaning)
      end
      -- Allocate memory for output buf and add to pool
      out_bufs[col_idx] = cmem.new(n_buf * binary_width)
      out_bufs[col_idx]:zero() -- extra cautious
      if ( M[col_idx].has_nulls ) then 
        nn_out_bufs[col_idx] = cmem.new(n_buf/8)
        nn_out_bufs[col_idx]:zero() -- extra cautious
      end
    end -- if is_load 
  end -- for col_idx = ...
  return cols, dicts, out_bufs, nn_out_bufs, n_buf
end

return init_buffers
