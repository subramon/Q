local ffi     = require 'ffi'
local lgutils = require 'liblgutils'
local function mod_hmap_storage(label, n, mod_type)
  assert(type(label) == "string")
  assert(type(n) == "number")
  assert(n > 0)
  local bkttype = label .. "_rs_hmap_bkt_t";
  local n1 = ffi.sizeof(bkttype) * n -- for bkts
  local n2 = ffi.sizeof("bool")  * n -- for bkt_full
  if ( mod_type == "incr") then 
    lgutils.incr_mem_used(n)
    lgutils.incr_mem_used(n)
  elseif ( mod_type == "decr") then 
    lgutils.decr_mem_used(n)
    lgutils.decr_mem_used(n)
  else 
    error("Bad mod_type " .. mod_type)
  end
end
return  mod_hmap_storage
