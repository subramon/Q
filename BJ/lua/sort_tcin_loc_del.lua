local Q = require 'Q'
local Scalar = require 'libsclr'

local function sort_tcin_loc_del(tcin, location_id, to_del, is_debug)
  if ( type(is_debug) == "nil" ) then
    is_debug = false
  end
  assert(type(is_debug) == "boolean")
  assert(type(tcin) == "lVector")
  assert(type(location_id) == "lVector")
  assert(type(to_del) == "lVector")
  assert(tcin:num_elements() == location_id:num_elements())
  assert(tcin:num_elements() == to_del:num_elements())
  --=================================================
  local num_to_del = Q.sum(to_del):eval()
  local x = Q.shift_left(tcin, 1)
  local y = Q.shift_left(location_id, 1)
  local z = Q.vvor(y, to_del)
  --=================================================
  local compkey = Q.concat(x, z)
  local one = Scalar.new(1, compkey:qtype())
  if ( is_debug ) then 
    assert(Q.sum(Q.vsand(compkey, one)):eval() == num_to_del)
  end 
  local srt_compkey = Q.sort(compkey, "asc")
  srt_compkey = srt_compkey:lma_to_chunks()
  
  if ( is_debug ) then 
    assert(srt_compkey:num_elements() == compkey:num_elements())
    assert(srt_compkey:num_chunks()   == compkey:num_chunks())
    assert(Q.sum(Q.vsand(srt_compkey, one)):eval() == num_to_del)
  end 
  local to_del   = Q.vconvert(Q.vsand(srt_compkey, one), "I1")
  local tcin_loc = Q.shift_right(srt_compkey, 1)
  to_del:eval() -- XXXX 
  tcin_loc:eval() -- XXXX 
  return tcin_loc, to_del 
end
return  sort_tcin_loc_del
