local ffi		= require 'Q/UTILS/lua/q_ffi'
local cmem		= require 'libcmem'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'
--======================================================
local function chk_data(X)
  local data_len
  local n_cols 
  assert( ( X ) and ( type(X) == "table" ) )
  for k, v in pairs(X) do 
    assert(type(v) == "lVector" )
    assert(v:is_eov())
    assert(not v:has_nulls())
    assert(v:fldtype() == "F4", "currently only F4 data is supported")
    if ( not n_cols ) then 
      data_len = v:length()
      n_cols = 1
    else
      assert(data_len == v:length())
      n_cols = n_cols + 1 
    end
  end
  assert(n_cols >= 1 )
  --=======================
  return n_cols, data_len
end
return chk_data
