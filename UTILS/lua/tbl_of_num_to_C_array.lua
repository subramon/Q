local ffi    = require 'ffi'
local cutils = require 'libcutils'
local cmem   = require 'libcmem'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'

local function tbl_of_num_to_C_array(J, qtype)
  assert(type(J) == "table")
  assert(#J > 0)
  assert(type(qtype) == "string")
  local ctype = assert(cutils.str_qtype_to_str_ctype(qtype))
  local width = assert(cutils.get_width_qtype(qtype))
  local bufsz = width * #J
  local outbuf = cmem.new({size = bufsz, qtype = qtype})
  local cptr = get_ptr(outbuf, qtype)

  for i, numval in ipairs(J) do 
    assert(type(numval) == "number")
    cptr[i-1] = numval
  end
  return outbuf
end
return tbl_of_num_to_C_array
