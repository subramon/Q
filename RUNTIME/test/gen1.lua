local ffi = require 'ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'  
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local counter = 1
local chunk_size = qconsts.chunk_size
local qtype = "I4"
local width = qconsts.qtypes[qtype].width
local bytes_to_alloc = width * chunk_size
local b1 = cmem.new(bytes_to_alloc, qtype, "gen1_buffer")

local function gen1(chunk_idx, col)
  if ( chunk_idx == 8 ) then 
    return 0, nil, nil 
  end
  local iptr = assert(get_ptr(b1, qtype))
  for i = 1, chunk_size do
    iptr[i-1] = counter
    counter = counter + 1
  end
  return chunk_size, b1, nil
end
return gen1

