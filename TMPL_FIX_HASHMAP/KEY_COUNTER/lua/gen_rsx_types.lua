local plpath = require 'pl.path'
local plfile = require 'pl.file'
local function gen_rsx_types(
  configs
  )
  assert(type(configs) == "table")
  local label = configs.label
  assert(type(label) == "string")

  local keytype = label .. "_rs_hmap_key_t"
  local valtype = label .. "_rs_hmap_val_t"
  local X = {}
  X[#X+1] = "#ifndef " .. label .. "_RSX_TYPES_H"
  X[#X+1] = "#define " .. label .. "_RSX_TYPES_H"
  X[#X+1] = "#include <stdint.h>"
  X[#X+1] = "typedef struct _" .. valtype .. "{" 
  X[#X+1] = [[
  uint32_t count; // 0 <= run_count <= count
  uint32_t guid; 
]]
  X[#X+1] = "} " .. valtype .. ";" 
  --------------------------------
  X[#X+1] = "typedef struct _" .. keytype .. "{" 
  for k, v in pairs(configs.key_types) do 
    local n1, n2 = string.find(v, "char:")
    if ( n1 == 1 ) then
      assert(n2 == n1+string.len("char:") -1)
      local len = string.sub(v, n2+1)
      assert(tonumber(len))
      X[#X+1] = "  char key" .. tostring(k) .."[" .. len .. "];"
    else
      X[#X+1] = "  " .. v .. " key" .. tostring(k)  .. "; "
    end
  end
  X[#X+1] = "} " .. keytype .. ";" 
  --------------------------------
  X[#X+1] = "#endif // " .. label .. "_RSX_TYPES_H"
  return  table.concat(X, "\n")
end
return gen_rsx_types
