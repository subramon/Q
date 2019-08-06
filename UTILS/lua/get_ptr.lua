local ffi = require 'ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local function get_ptr(
  x, 
  qtype -- optional 
)
  if not x then return nil end
  local ret_ptr 
  assert(type(x) == "CMEM")
  local y = ffi.cast("CMEM_REC_TYPE *", x)
  
  -- Made qtype optional
  if qtype then
    if ( qtype == "uint8_t" ) then 
      ret_ptr = ffi.cast(qtype .. " *", y[0].data)
    else
      assert(qconsts.qtypes[qtype])
      local ctype = assert(qconsts.qtypes[qtype].ctype)
      ret_ptr = ffi.cast(ctype .. " *", y[0].data)
    end
  else
    ret_ptr = y[0].data
  end
  return ret_ptr
end
return get_ptr
