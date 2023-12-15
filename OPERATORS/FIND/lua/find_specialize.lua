local cutils = require 'libcutils'
local is_in = require 'Q/UTILS/lua/is_in'
local to_scalar = require 'Q/UTILS/lua/to_scalar'

local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8", }
-- TODO P3 Need to support unsigned as well but that needs work in
-- Scalars to support comparisons for those types as well
--  { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", "F4", "F8", }
return function(invec, elem)
  local subs = {}

  assert(type(invec) == "lVector")
  assert(invec:is_eov())
  assert(not invec:has_nulls())

  local curr_sort_order = invec:get_meta("sort_order")
  assert(type(curr_sort_order) == "string")
  assert(curr_sort_order == "asc")

  subs.qtype = invec:qtype()
  assert(is_in(subs.qtype , qtypes))

  if ( type(elem) == "Scalar" ) then 
    subs.sclr = elem
  elseif ( type(elem) == "number" ) then 
    subs.sclr = assert(to_scalar(elem, subs.qtype))
  else
    error("bad element to search for")
  end
  return subs
end
