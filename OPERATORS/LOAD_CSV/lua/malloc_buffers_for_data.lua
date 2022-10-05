local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
local qcfg    = require 'Q/UTILS/lua/qcfg'

local max_num_in_chunk = qcfg.max_num_in_chunk

local function malloc_buffers_for_data(M)
  local databuf = {}
  local nn_databuf = {}
  for k, v in ipairs(M) do
    local qtype = v.qtype
    local bufsz = v.width * max_num_in_chunk
    if ( v.is_load ) then 
      databuf[v.name] = cmem.new(
      { size = bufsz, qtype = qtype, name = v.name})
      databuf[v.name]:stealable(true)
      if ( v.has_nulls ) then
        if ( v.nn_qtype == "B1" ) then 
          nn_databuf[v.name] = cmem.new(
          { size = max_num_in_chunk/8, "B1", name = "nn_ " .. v.name})
        elseif ( v.nn_qtype == "BL" ) then 
          nn_databuf[v.name] = cmem.new(
          { size = max_num_in_chunk * 1 , "BL", name = "nn_ " .. v.name})
        else
          error("")
        end
        nn_databuf[v.name]:stealable(true)
      end
    end
  end
  return databuf, nn_databuf
end
return malloc_buffers_for_data
