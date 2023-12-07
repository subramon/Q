local Q = require 'Q'
local Scalar = require 'libsclr'

local function sort_tcin_loc_del(tcin, location_id, to_del, 
    with_idx, is_debug)
  assert(type(with_idx) == "boolean")
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
  r:delete()
  local x = Q.shift_left(tcin, 1)
  local y = Q.shift_left(location_id, 1)
  -- location_id:eval(); location_id:pr("_locaton_id")
  -- y:eval(); y:pr("_shifted_location_id")
  if ( is_debug ) then 
    local n1, n2 = Q.min(to_del):eval()
    assert(n1:to_num() >= 0)
    local n1, n2 = Q.max(to_del):eval()
    assert(n1:to_num() <= 1)
  end
  local z = Q.vvor(y, to_del):eval()
  y:delete()
  --=================================================
  local compkey = Q.concat(x, z):eval()
  if ( is_debug ) then 
    local X = Q.split(compkey, { out_qtypes = { "I4", "I4"}})
    X[1]:eval()
    local n1, n2 = Q.sum(Q.vveq(X[1], x)):eval()
    assert(n1 == n2)
    local n1, n2 = Q.sum(Q.vveq(X[2], z)):eval()
    assert(n1 == n2)
    -- X[2]:pr()
    X[1]:delete()
    X[2]:delete()
  end
  x:delete()
  z:delete()
  local one = Scalar.new(1, compkey:qtype())
  if ( is_debug ) then 
    local x = Q.vsand(compkey, one)
    local r = Q.sum(x)
    local n1 = r:eval()
    assert(n1 == num_to_del)
    x:delete()
    r:delete()
  end 
  local srt_compkey, srt_idx
  local len = tcin:num_elements()
  if ( with_idx ) then 
    local idx = Q.seq({start = 0, by = 1, qtype = "I4", len = len}):eval()
    x, y = Q.idx_sort(idx, compkey, "asc")
    srt_idx     = x:lma_to_chunks(); x:delete()
    srt_compkey = y:lma_to_chunks(); y:delete()
    Q.print_csv({srt_compkey, srt_idx}, { opfile = "_sorted.csv"})
    idx:delete()
  else
    y = Q.sort(compkey, "asc")
    srt_compkey = y:lma_to_chunks(); y:delete()
  end
  
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
  return tcin_loc, out_to_del, srt_idx
end
return  sort_tcin_loc_del
