local qconsts       = require 'Q/UTILS/lua/q_consts'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local cmem          = require 'libcmem'
local function malloc_buffers_for_data(M)

  local nC = #M; assert(nC > 0 )
  local databuf = {}
  local nn_databuf = {}
  local cdata    = ffi.cast("void     **", 
    get_ptr(cmem.new(ffi.sizeof("void *") * nC)))
  local nn_cdata = ffi.cast("uint64_t **", 
    get_ptr(cmem.new(ffi.sizeof("uint64_t *") * nC)))
  for i = 1, nC do 
    nn_cdata[i-1] = ffi.NULL
    cdata[i-1] = ffi.NULL
  end
  for i, v in pairs(M) do
    local qtype = v.qtype
    local ctype = qconsts.qtypes[qtype].ctype
    local bufsz = v.width * qconsts.chunk_size
    if ( v.is_load ) then 
      databuf[v.name] = cmem.new(bufsz, qtype, v.name, 64)
      print("Allocating ", bufsz , " for ", v.name)
      cdata[i-1]  = get_ptr(databuf[v.name] , qtype)
      if ( v.has_nulls ) then
        assert(nil, "UNDO THIS JUST FOR TESTING:")
        -- TODO P4 You are over-allocating. Cut this down
        nn_databuf[v.name] = cmem.new(qconsts.chunk_size, "I1", v.name, 64)
        nn_cdata[i-1] = ffi.cast("uint64_t *", get_ptr(nn_databuf[v.name]))
      end
    end
  end
  return databuf, nn_databuf, cdata, nn_cdata
end
return malloc_buffers_for_data
