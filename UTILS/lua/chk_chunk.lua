local qconsts = require 'Q/UTILS/lua/q_consts'
local function chk_chunk_return(x_len, x_chunk, nn_x_chunk)
  -- TODO Is following if statement idiomatically sound?
  if ( qconsts.debug ) and ( qconsts.debug == true ) then
    if ( x_len ) then 
      assert(type(x_len) == "number")
      assert(x_len >= 0)
      if ( x_len > 0 ) then 
        assert(x_chunk)
        -- TODO P1 Under what conditions would we get userdata?
        assert((type(x_chunk) == "CMEM") or (type(x_chunk) == "userdata") )
      else
        assert(not x_chunk) 
        assert(not nn_x_chunk) 
      end
    end 
    if ( nn_x_chunk ) then assert(x_chunk) end 
  else
    return true
  end
  return true
end
return chk_chunk_return
