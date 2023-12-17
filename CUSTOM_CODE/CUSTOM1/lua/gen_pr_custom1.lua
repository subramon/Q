local x = [[
  if ( (x->bmask & ((uint64_t)1 << __IDX__)) != 0 ) {
    sprintf(tmp, "\"__TERM__\" : %f ", x->__TERM__);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }
]]

local terms = require 'Q/CUSTOM_CODE/CUSTOM1/lua/custom1_spec'
local outfile = "../src/gen_pr_custom1.c"
local fp = assert(io.open(outfile, "w"))

local mcr_def = [[
#define  mcr_pr_comma() { \
  if ( first ) {  \
    first = false; \
  } \
  else {  \
    status = cat_to_buf(&out, &bufsz, &buflen, ", ", 2);  \
  } \
}
]]
-- NOT NEEDED I THINK   fp:write(mcr_def)
for k, v in ipairs(terms) do 
  local y = string.gsub(x, "__TERM__", v)
  local y = string.gsub(y, "__IDX__", k-1)
  fp:write(y)
  fp:write("\n  /*-------------------------------------------------*/\n")
end
fp:close()

print("Created file ", outfile)
