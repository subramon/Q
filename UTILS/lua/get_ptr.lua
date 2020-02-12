local ffi = require 'ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_func_decl = require 'Q/UTILS/build/get_func_decl'

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

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
    assert(type(qtype) == "string")
    if ( qconsts.qtypes[qtype] ) then 
      local ctype = assert(qconsts.qtypes[qtype].ctype)
      ret_ptr = ffi.cast(ctype .. " *", y[0].data)
    else
      local cast_as = qtype 
      assert(ends_with(trim(qtype), "*"))
      ret_ptr = ffi.cast(cast_as, y[0].data)
    end
  else
    ret_ptr = ffi.cast("char *", y[0].data)
  end
  return ret_ptr
end
return get_ptr
