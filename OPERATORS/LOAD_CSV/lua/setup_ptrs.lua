local ffi  = require 'ffi'
local cmem = require 'libcmem'
local get_ptr       = require "Q/UTILS/lua/get_ptr"
local function setup_ptrs(M, databuf, nn_databuf, cdata, nn_cdata)
  assert(cdata)
  assert(nn_cdata)
  assert(type(databuf)    == "table")
  assert(type(nn_databuf) == "table")
  for k, v in pairs(M) do 
    if ( v.is_load ) then 
      assert(type(databuf[v.name]) == "CMEM")
      if ( v.has_nulls) then 
        assert(type(nn_databuf[v.name]) == "CMEM")
      end
    end
  end

  for i, v in ipairs(M) do
    nn_cdata[i-1] = ffi.NULL
    cdata   [i-1] = ffi.NULL
    if ( v.is_load ) then 
      cdata[i-1]  = get_ptr(databuf[v.name])
      if ( v.has_nulls ) then
        nn_cdata[i-1] = get_ptr(nn_databuf[v.name])
      end
    end
  end
end
return setup_ptrs
