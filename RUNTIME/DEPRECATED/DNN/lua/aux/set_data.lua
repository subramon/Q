local ffi = require 'ffi'
local cmem		= require 'libcmem'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'
--======================================================
local function set_data(X, lbl)
  -- Since we will randomize the input, we have to make a copy of it
  local lX = {}
  local n_cols = 0
  for _, v in pairs(X) do 
    n_cols = n_cols + 1 
    lX[n_cols] = v:clone()
  end
  --=======================
  -- We set up an array of pointers to the data of each vector
  local sz = ffi.sizeof("float *") * n_cols
  local lptrs = cmem.new(sz, "PTR", lbl)
  assert(lptrs)
  --=======================
  return lX, lptrs
end
return set_data
