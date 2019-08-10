local qconsts = require 'Q/UTILS/lua/q_consts'
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/lua/TM_to_I2.tmpl"
local function TM_to_I2_specialize(tm_fld)
  local subs = {}
  assert(type(tm_fld) == "string")

  local fn 
 if ( tm_fld == "tm_sec" ) then fn = "TM_to_sec"  end 
 if ( tm_fld == "tm_min" ) then fn = "TM_to_min" end 
 if ( tm_fld == "tm_hour" ) then fn = "TM_to_hour" end 
 if ( tm_fld == "tm_mday" ) then fn = "TM_to_mday" end 
 if ( tm_fld == "tm_mon" ) then fn = "TM_to_mon" end 
 if ( tm_fld == "tm_year" ) then fn = "TM_to_year" end 
 if ( tm_fld == "tm_wday" ) then fn = "TM_to_wday" end 
 if ( tm_fld == "tm_yday" ) then fn = "TM_to_yday" end 
 if ( tm_fld == "tm_isdst" ) then fn = "TM_to_isdst" end 
 assert(fn)
 subs.fn = fn
 subs.tm_fld = tm_fld
 subs.tmpl = tmpl 
 return subs
end
return  TM_to_I2_specialize
