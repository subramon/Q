local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
local cVector = require 'libvctr'


local function malloc_buffers_for_data(M, max_num_in_chunk)
  -- the prefix l_ stands for Lua 
  -- we use the prefix c_ for what goes to C 
  local l_data = {} 
  local nn_l_data = {}
  for k, v in ipairs(M) do
    -- special case need below 
    if ( v.is_load ) then 
      local bufsz = v.width * max_num_in_chunk
      assert(v.nn_qtype ~= "B1" ) -- TODO to be implemente
      l_data[v.name] = cmem.new(
        { size = bufsz, qtype = v.qtype, name = "_" .. v.name})
      l_data[v.name]:stealable(true)
      if ( v.has_nulls ) then
        if ( v.nn_qtype == "B1" ) then bufsz = max_num_in_chunk / 8 end 
        if ( v.nn_qtype == "BL" ) then bufsz = max_num_in_chunk     end 
        local nn_name = "_" .. "nn_" .. v.name
        cVector.check_all(true, true)
        nn_l_data[v.name] = cmem.new(
          {size = bufsz, qtype = "B1", name = nn_name})
        nn_l_data[v.name]:stealable(true)
      end
    end
  end
  -- print("Created Lua buffers for data ")
  --=== Make the buffers here accessible to C 
  local c_data = cmem.new(ffi.sizeof("char *") * #M)
  c_data = get_ptr(c_data, "char **")

  local nn_c_data = cmem.new(ffi.sizeof("char *") * #M)
  nn_c_data = get_ptr(nn_c_data, "char **")

  for i, v in ipairs(M) do
    c_data   [i-1] = ffi.NULL
    nn_c_data[i-1] = ffi.NULL
    if ( v.is_load ) then 
      c_data[i-1]  = get_ptr(l_data[v.name])
      if ( v.has_nulls ) then
        nn_c_data[i-1] = get_ptr(nn_l_data[v.name])
      end
    end
  end
  -- print("Created C buffers for data ")
  return l_data, nn_l_data, c_data, nn_c_data 
end
return malloc_buffers_for_data
