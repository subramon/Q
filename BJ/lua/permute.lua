local Q = require 'Q'
local function permute(srt_ordr, tbl, keys)
  assert(type(srt_ordr) == "lVector")
  assert(type(tbl) == "table")
  assert(type(keys) == "table")
  assert(#keys >= 1)
  for k, v in ipairs(keys) do 
    assert(type(v) == "string")
    assert(type(tbl[v]) == "lVector")
  end
  for k, v in ipairs(keys) do 
    local x = tbl[v]:chunks_to_lma()
    local y = Q.permute_from(x, srt_ordr):eval()
    x:delete(); 
    tbl[v]:delete(); 
    tbl[v] = y
  end
end
return permute
