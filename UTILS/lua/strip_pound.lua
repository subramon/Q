local function strip_pound(
  fname
  )
  local X = {}
  local file = assert(io.open(fname, "r"))
  for line in file:lines() do
    local n1, _ = string.find(line, "#include")
    local n2, _ = string.find(line, "#ifndef")
    local n4, _ = string.find(line, "#define")
    local n3, _ = string.find(line, "#endif")
    if ( n1 or n2 or n3 or n4 ) then 
      -- print(">>> Skipping " .. line)
    else
      X[#X+1] = line
    end
  end
  file:close()
  return table.concat(X, "\n")
end
return strip_pound
--[[
-- quick and dirty testing 
local fname = "/home/subramon/Q/TMPL_FIX_HASHMAP/inc/rs_hmap_config.h"
local x = strip_pound(fname)
print(x)
--]]
