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
  --=================================================
  local r = Q.sum(to_del)
  local num_to_del = r:eval()
  local x = Q.shift_left(tcin, 1)
  local y = Q.shift_left(location_id, 1)
  local z = Q.vvor(y, to_del)
  --=================================================
  local compkey = Q.concat(x, z)
  local one = Scalar.new(1, compkey:qtype())
  if ( is_debug ) then 
    local x = Q.vsand(compkey, one)
    local r = Q.sum(x)
    local n1 = r:eval()
    assert(n1 == num_to_del)
    x:delete()
    r:delete()
  end 
  local srt_compkey = Q.sort(compkey, "asc")
  srt_compkey = srt_compkey:lma_to_chunks()
  
  if ( is_debug ) then 
    assert(srt_compkey:num_elements() == compkey:num_elements())
    assert(srt_compkey:num_chunks()   == compkey:num_chunks())
    local x = Q.vsand(srt_compkey, one)
    local r = Q.sum(x)
    local n1 = r:eval()
    assert(n1 == num_to_del)
    x:delete()
    r:delete()
  end 
  local w   = Q.vsand(srt_compkey, one)
  local out_to_del   = Q.vconvert(w, "I1")
  local tcin_loc = Q.shift_right(srt_compkey, 1)
  -- START: Just for testing 
  out_to_del:eval() -- XXXX 
  tcin_loc:eval() -- XXXX 

  r:delete()
  x:delete()
  y:delete()
  z:delete()
  w:delete()
  compkey:delete()
  srt_compkey:delete()
  to_del:delete()
  -- STOP : Just for testing 
  return tcin_loc, out_to_del 
end
return  sort_tcin_loc_del
