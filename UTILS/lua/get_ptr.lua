local ffi = require 'ffi'
local cutils = require 'libcutils'
local qc      = require 'Q/UTILS/lua/qcore'
qc.q_cdef("UTILS/inc/qtypes.h")

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

local function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- TODO P2 Do we still need thislocal is_cdef = false
local function get_ptr(
  x,
  qtype -- optional
)
  if not x then return nil end
  local ret_ptr
  assert(type(x) == "CMEM")
  local y = x:data()
  -- Made qtype optional
  if qtype then
    assert(type(qtype) == "string")
    local ctype = cutils.str_qtype_to_ctype(qtype)
    if ( ctype == ffi.NULL ) then 
      local cast_as = qtype
      assert(ends_with(trim(qtype), "*"))
      ret_ptr = ffi.cast(cast_as, y)
    else
      ret_ptr = ffi.cast(ctype .. " *", y)
    end
  else
    ret_ptr = ffi.cast("char *", y)
  end
  return ret_ptr
end
return get_ptr
