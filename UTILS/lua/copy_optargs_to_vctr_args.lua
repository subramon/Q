local is_in = require 'Q/UTILS/lua/is_in'
local good_args = { "name", "max_num_in_chunk", } -- WHAT ELSE? TODO P2 
local function copy_optargs_to_vctr_args(optargs)
  local vargs = {}
  if ( optargs ) then 
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do 
      vargs[k] = v
      -- NOTE: We should be more selective in what we put into vargs
      -- as shown below. Make sure good_args is complete before that
      --[[
      if ( is_in(k, good_args) ) then
        vargs[k] = v 
      end
      --]]
    end
  end
  return vargs
end
return copy_optargs_to_vctr_args
