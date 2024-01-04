local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_find(x, y, optargs)
  local specializer = "Q/OPERATORS/FIND/lua/find_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(x, y))
  assert(type(subs) == "table")

  -- binary search in Lua 
  local lb = 0 
  local ub = x:num_elements()
  local top_ub = ub
  local rslt = -1 
  local prev_pos = -1 
  while true do 
    local pos = math.floor((lb+ub)/2)
    if ( pos == top_ub ) then pos = pos - 1 end 
    if ( pos == prev_pos ) then break end 
    prev_pos = pos
    local z = assert(x:get1(pos))
    if ( subs.sclr == z ) then 
      rslt = pos 
      break 
    end
    if ( subs.sclr < z ) then ub = pos end 
    if ( subs.sclr > z ) then lb = pos end 
  end
  return rslt
end
return expander_find
