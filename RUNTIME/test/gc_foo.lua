-- following hard coded here for now 
local get_hdr = require 'Q/UTILS/lua/get_hdr'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'


local function gc_foo(n)
  local x = assert(cmem.new(1048576, "I4", "remainder"))
  x:zero()
  local c_x = get_ptr(x, "I4")


  local out = {}
  local iter = iter or n
  local function setter()
    if ( false ) then c_x = get_ptr(x, "I4") end -- comment to force bug
    c_x[0] = iter
    iter = iter + 1
  end
  local function getter()
    if ( false ) then c_x = get_ptr(x, "I4") end -- comment to force bug
    return tonumber(c_x[0])
  end
  out.setter = setter
  out.getter = getter
  return out
end
return gc_foo
