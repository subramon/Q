local qcfg = require 'Q/UTILS/lua/qcfg'
local function get_max_num_in_chunk(largs)
  local max_num_in_chunk = qcfg.max_num_in_chunk
  if ( largs ) then 
    assert(type(largs) == "table")
    local max_num_in_chunk = qcfg.max_num_in_chunk
    if ( largs.max_num_in_chunk ) then 
      assert(type(largs.max_num_in_chunk) == "number")
      max_num_in_chunk = largs.max_num_in_chunk
     assert(max_num_in_chunk > 0)
     assert( ( ( ( max_num_in_chunk / 64 ) * 64 ) == max_num_in_chunk))
    end
  end
  return max_num_in_chunk
end
return get_max_num_in_chunk
