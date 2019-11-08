local qconsts  = require 'Q/UTILS/lua/q_consts'
local function make_put1_return(T)
  local ccode = [[
    case __I__ :
      ptr_val_sclr->cdata.val__VALTYPE__ = oldval.val___I__;
      strcpy(ptr_val_sclr->field_type, "__VALTYPE__");
    break;
    ]]
  local Z = {}
  for i, v in ipairs(T.vals) do 
    local str = string.gsub(ccode, "__I__", tostring(i))
    Z[#Z+1]   = string.gsub(str,   "__VALTYPE__", v.valtype)
  end
  Z[#Z+1] = ""
  return table.concat(Z, "\n");
end
return make_put1_return
