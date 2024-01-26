local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'

local function data_buffers_for_C(M, l_data, nn_l_data)

  -- print("Created Lua buffers for data ")
  --=== Make the buffers here accessible to C 
  local size = ffi.sizeof("char *") * #M

  local c_data = cmem.new({size = size, name = "c_data"})
  c_data:zero()
  local x_data = get_ptr(c_data, "char **")

  local nn_c_data = cmem.new({size = size, name = "nn_c_data"})
  nn_c_data:zero()
  local nn_x_data = get_ptr(nn_c_data, "char **")

  for i, v in ipairs(M) do
    x_data   [i-1] = ffi.NULL
    nn_x_data[i-1] = ffi.NULL
    if ( v.is_load ) then 
      x_data[i-1]  = get_ptr(l_data[v.name])
      if ( v.has_nulls ) then
        nn_x_data[i-1] = get_ptr(nn_l_data[v.name], "char *")
      end
    end
  end
  return c_data, nn_c_data
end
return data_buffers_for_C

