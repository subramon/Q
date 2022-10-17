local is_in = require 'Q/UTILS/lua/is_in'
local cutils = require 'libcutils'

local function repeat_specialize(
  f1, -- vector whose value is to be repeated
  f2, -- number of times a value should be repeated
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())
  assert(type(f2) == "lVector"); assert(not f2:has_nulls())
  local f1_qtype = f1:qtype();   
  assert(is_in(f1_qtype, { "I1", "I2", "I4", "I8", "F4", "F8", "TM1", }))
  local f2_qtype = f2:qtype();   
  assert(is_in(f2_qtype, { "I1", "I2", "I4", "I8", }))
  assert(f1:max_num_in_chunk() == f2:max_num_in_chunk())
  subs.max_num_in_chunk = f1:max_num_in_chunk()

  subs.f3_qtype = f1_qtype
  subs.f3_width = cutils.get_width_qtype(subs.f3_qtype)
  subs.bufsz = subs.max_num_in_chunk * subs.f3_width 
  subs.cast_f3_as = cutils.str_qtype_to_str_ctype(subs.f3_qtype) .. " *"

  return subs
end
return repeat_specialize
