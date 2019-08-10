local ffi = require 'ffi'

local function gc_xxx(n)
  local width = ffi.sizeof("int")
  local sz = n * width
  local x = ffi.gc(ffi.C.malloc(sz), ffi.C.free)
--   local y = ffi.cast("int *", x)
  local y = ffi.gc(ffi.cast("int *", ffi.gc(x, nil)), ffi.C.free)

  local out = {}
  local iter = iter or n
  local function setter()
    -- if ( false ) then y = get_ptr(x, "I4") end -- comment to force bug
    y[0] = iter
    iter = iter + 1
  end
  local function getter()
    -- if ( false ) then y = get_ptr(x, "I4") end -- comment to force bug
    return tonumber(y[0])
  end
  out.setter = setter
  out.getter = getter
  return out
end
return gc_xxx
