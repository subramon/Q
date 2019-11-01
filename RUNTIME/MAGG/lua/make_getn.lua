local qconsts  = require 'Q/UTILS/lua/q_consts'
local function make_getn(T)
  local ccode =  [[
  case __I__ : 
    for ( int j = 0; j < num_keys; j++ ) {
      ((__CVALTYPE__ *)ptr_val->data)[j] = 
        ptr_agg->ptr_bufs->mvals[j].val___I__;
    }
    break;
  ]]
  local V = {}
  for i, v in ipairs(T.vals) do 
    local cvaltype = qconsts.qtypes[v.valtype].ctype
    local str = string.gsub(ccode, "__I__", tostring(i))
    V[#V+1] = string.gsub(str, "__CVALTYPE__", cvaltype)
  end
  V[#V+1] = ""
  return table.concat(V, "\n");
end

return make_getn
