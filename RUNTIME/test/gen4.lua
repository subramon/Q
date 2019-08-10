local ffi = require 'ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'  
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local counter = 1
local qtype = "I4"
local chunk_size = qconsts.chunk_size
local width = qconsts.qtypes[qtype].width
local base_data = cmem.new(chunk_size * width, qtype, "data for gen4")

local function gen4(chunk_idx, col)
  if ( chunk_idx == 3 ) then
    -- generate less than chunk size values for this chunk
    chunk_size = 10 
  end
  local iptr = assert(get_ptr(base_data, qtype))
  for i = 1, chunk_size do
    iptr[i-1] = counter
    counter = counter + 1
  end
  return chunk_size, base_data, nil
end
return gen4
