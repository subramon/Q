local qconsts  = require 'Q/UTILS/lua/q_consts'
local function make_put1(T)
  local Z = {}
  local ccode = [[
  case __I__ : 
    newval.val___I__ = ptr_val->cdata.val__VALTYPE__;
  break;
  ]]
  for i, v in ipairs(T.vals) do 
    local str = string.gsub(ccode, "__I__", tostring(i))
    Z[#Z+1]   = string.gsub(str,   "__VALTYPE__", v.valtype)
  end
  Z[#Z+1] = ""
  return  table.concat(Z, "\n");
end
return make_put1
