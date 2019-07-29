local qconsts = require 'Q/UTILS/lua/q_consts'
local function chk_chunk_return(
  x_len, 
  x_chunk, 
  nn_x_chunk
  )
  -- TODO P4 Is following if statement idiomatically sound?
  if ( qconsts.debug ) and ( qconsts.debug == true ) then
    if ( x_len ) then 
      assert(type(x_len) == "number")
      assert(x_len >= 0)
      if ( x_len > 0 ) then 
        assert(x_chunk)
        assert(type(x_chunk) == "CMEM")
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
