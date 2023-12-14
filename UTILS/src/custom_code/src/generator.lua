local x = [[
    x = json_object_get(root, "__TERM__");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << __IDX__);
      if ( json_is_real(x) ) { 
        Y[i].__TERM__ = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].__TERM__ = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }
]]

local terms = require 'Q/UTILS/src/custom1_terms'
local outfile = "generated_code.c"
local fp = assert(io.open("generated_code.c", "w"))

for k, v in ipairs(terms) do 
  local y = string.gsub(x, "__TERM__", v)
  local y = string.gsub(y, "__IDX__", k-1)
  fp:write(y)
  fp:write("\n    /*-------------------------------------------------*/\n")
end
fp:close()

print("Created file ", outfile)
