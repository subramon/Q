local qconsts       = require 'Q/UTILS/lua/qconsts'
local ffi           = require 'ffi'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local cmem          = require 'libcmem'
local qmem    = require 'Q/UTILS/lua/qmem'
local chunk_size = qmem.chunk_size

local function malloc_buffers_for_data(M)
  local cdata, nn_cdata
  local databuf, nn_databuf 
  cdata    = assert(cmem.new(
   { size = ffi.sizeof("char *") * #M,  name = "cdata"}))

  nn_cdata = assert(cmem.new(
  { size = ffi.sizeof("uint64_t *") * #M, name = "nn_cdata"}))

  databuf = {}
  nn_databuf = {}
  for _, v in ipairs(M) do
    local qtype = v.qtype
    local ctype = qconsts.qtypes[qtype].ctype
    local bufsz = v.width * chunk_size
    if ( v.is_load ) then 
      databuf[v.name] = cmem.new(
      { size = bufsz, qtype = qtype, name = v.name})
      if ( v.has_nulls ) then
        nn_databuf[v.name] = cmem.new(
        { size = chunk_size/8, "B1", name = "nn_ " .. v.name})
      end
    end
  end
  return databuf, nn_databuf, cdata, nn_cdata
end
return malloc_buffers_for_data
