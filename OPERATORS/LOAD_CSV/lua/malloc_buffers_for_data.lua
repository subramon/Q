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
  for i, v in pairs(M) do
    local qtype = v.qtype
    local ctype = qconsts.qtypes[qtype].ctype
    local bufsz = v.width * qconsts.chunk_size
    if ( v.is_load ) then 
      databuf[v.name] = cmem.new(bufsz, qtype, v.name, 64)
      cdata[i-1]  = get_ptr(databuf[v.name] , qtype)
    else
      cdata[i] = ffi.NULL
    end
    --=======================================
    if ( v.has_nulls ) then
      assert(nil, "TO BE IMPLEMENTED TODO P1")
      nn_cdata[i] = ffi.cast("uint64_t *", 
        get_ptr(cmem.new(qconsts.chunk_size, "B1", v.name, 64)))
    else
      nn_cdata[i] = ffi.NULL
    end
  end
  return databuf, nn_databuf, cdata, nn_cdata
end
return malloc_buffers_for_data
