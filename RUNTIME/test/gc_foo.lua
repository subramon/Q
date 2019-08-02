-- following hard coded here for now 
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local get_hdr = require 'Q/UTILS/lua/get_hdr'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem = require 'libcmem'
--=======================================
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function gc_foo(n)
  local x = assert(cmem.new(1048576, "I4", "remainder"))
  x:zero()
 -- THIS CAUSES A PROBLEM    local c_x = get_ptr(x, "I4")

  local out = {}
  local iter = iter or n
  local function setter()
    local c_x = get_ptr(x, "I4")
    c_x[0] = iter
    iter = iter + 1
  end
  local function getter()
    local c_x = get_ptr(x, "I4")
    return tonumber(c_x[0])
  end
  out.setter = setter
  out.getter = getter
  return out
end
return gc_foo
