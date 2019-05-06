local qconsts       = require 'Q/UTILS/lua/q_consts'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local function malloc_buffers_for_data(M)

  local data    = ffi.cast("void     **", 
    get_ptr(cmem.newffi.sizeof("void **") * nC))
  local nn_data = ffi.cast("uint64_t **", 
    get_ptr(cmem.new(ffi.sizeof("uint64_t **") * nC)))
  ffi.fill(data,    ffi.sizeof("void **") * nC) -- sets to 0
  ffi.fill(nn_data, ffi.sizeof("void **") * nC) -- sets to 0
  for i, v in pairs(M) do
    local qtype = v.qtype
    local ctype = qconsts.qtypes[qtype].ctype
    local bufsz = v.width * qconsts.chunk_size
    if ( v.is_load ) then 
      local xptr = get_ptr(cmem.new(bufsz, qtype, v.name, 64))
      if ( qtype == "B1)" ) then 
        data[i-1]  = ffi.cast("uint64_t *", bufsz)
      elseif ( qtype == "SC)" ) then 
        data[i-1]  = ffi.cast("char *", bufsz)
      else
        data[i-1]  = ffi.cast(qtype .. " *", bufsz)
      end
    else
    end
    if ( v.has_nulls ) then
      nn_data[i] = ffi.cast("uint64_t *", 
        get_ptr(cmem.new(qconsts.chunk_size, "B1", v.name, 64)))
    end
  end
  return data, nn_data
end
  --=======================================
