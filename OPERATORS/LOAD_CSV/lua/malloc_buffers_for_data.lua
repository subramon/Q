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
  return l_data, nn_l_data
end
return malloc_buffers_for_data
