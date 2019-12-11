local ffi = require 'ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_func_decl = require 'Q/UTILS/build/get_func_decl'

-- TODO P2 Do we still need thislocal is_cdef = false
local function get_ptr(
  x, 
  qtype -- optional 
)

  if not x then return nil end
  --[[ TODO P2 Do we still need this?
  if ( not is_cdef ) then 
    local incs = "-I" .. qconsts.Q_SRC_ROOT .. "/UTILS/inc/"
    local doth = qconsts.Q_SRC_ROOT .. "/RUNTIME/CMEM/inc/cmem_struct.h"
    local hdrs = get_func_decl(doth, incs)
    ffi.cdef(hdrs)
    is_cdef = true
  end
  --]]

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
