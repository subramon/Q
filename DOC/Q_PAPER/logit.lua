local qconsts	= require 'Q/UTILS/lua/q_consts'
local cmem	= require 'libcmem'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local lVector	= require 'Q/RUNTIME/lua/lVector'
local ffi	= require 'Q/UTILS/lua/q_ffi'

local function logit(v)
  local qtype = v:fldtype()
  local n     = qconsts.chunk_size
  local w     = qconsts.qtypes[qtype].width
  local d2    = cmem.new(n*w, qtype, "buffer")
  local cd2   = get_ptr(d2, qtype)
  local v2    = lVector({gen = true, qtype = qtype, has_nulls = false})
  local cidx = 0 -- chunk index
  while true do 
    local n1, d1 = v:chunk(cidx)
    -- quit when no more input
    if ( n1 == 0 ) then break end 
    local ctype = qconsts.qtypes[qtype].ctype
    -- access data of input
    local cd1 = ffi.cast(ctype .. "*", get_ptr(d1)) 
    for i = 0, n1 do -- core operation is as follows
      cd2[i] = 1.0 / (1.0 + math.exp(-1 * cd1[i]))
    end
    v2:put_chunk(d2, nil, n1) -- pass buffer to output vector
    cidx = cidx + 1 -- start work on next chunk
  end
  v2:eov() -- no more data
  return v2
end

return logit
