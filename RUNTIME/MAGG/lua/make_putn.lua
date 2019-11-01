local qconsts  = require 'Q/UTILS/lua/q_consts'
local function make_putn(T)
  local W = {}
  local ccode = [[
  case __I__ : 
    for ( int j = 0; j < num_keys; j++ ) { 
      ptr_agg->ptr_bufs->mvals[j].val___I__ = 
        ((__CVALTYPE__ *)ptr_val->data)[j];
    }
    break;
    ]]
  for i, v in ipairs(T.vals) do 
    local cvaltype = qconsts.qtypes[v.valtype].ctype
    local str = string.gsub(ccode, "__I__", tostring(i))
    W[#W+1]   = string.gsub(str, "__CVALTYPE__", cvaltype)
  end
  W[#W+1] = ""
  return table.concat(W, "\n");
end
return make_putn
