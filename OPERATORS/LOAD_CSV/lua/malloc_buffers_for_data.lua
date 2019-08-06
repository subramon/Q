local qconsts       = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local cmem          = require 'libcmem'
local function malloc_buffers_for_data(M)

  local nC = #M; assert(nC > 0 )
  local databuf = {}
  local nn_databuf = {}
  local cdata    = ffi.cast("char     **", 
    get_ptr(cmem.new(ffi.sizeof("char *") * nC, "UNK", "cdata")))
  local nn_cdata = ffi.cast("uint64_t **", 
    get_ptr(cmem.new(ffi.sizeof("uint64_t *") * nC, "I8", "nn_cdata")))
  for i = 1, nC do 
    nn_cdata[i-1] = ffi.NULL
       cdata[i-1] = ffi.NULL
  end
  for i, v in pairs(M) do
    local qtype = v.qtype
    local ctype = qconsts.qtypes[qtype].ctype
    local bufsz = v.width * qconsts.chunk_size
    if ( v.is_load ) then 
      -- print("getting buffer for ", v.name, bufsz)
      databuf[v.name] = cmem.new(bufsz, qtype, v.name)
      -- print("done getting buffer for ", v.name)
      cdata[i-1]  = get_ptr(databuf[v.name])
      if ( v.has_nulls ) then
        -- TODO P4 You are over-allocating. Cut this down
        nn_databuf[v.name] = 
          cmem.new(qconsts.chunk_size, "I1", "nn_ " .. v.name)
        nn_cdata[i-1] = get_ptr(nn_databuf[v.name])
      end
    end
    -- print("LUA", cdata, nn_cdata, cdata[0], nn_cdata[0])
  end
  return databuf, nn_databuf, cdata, nn_cdata
end
return malloc_buffers_for_data
