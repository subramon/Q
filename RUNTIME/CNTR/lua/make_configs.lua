-- make the configs needed by make_kc_so to generate C custom code
-- for key counter
local function make_configs(label, vecs)
  local configs = {}
  configs.label = label
  local n = 0
  local qtypes = {}
  for k, v in ipairs(vecs) do 
    assert(type(v) == "lVector")
    local qtype = v:qtype()
    if ( qtype == "I1" ) then 
      qtypes[#qtypes+1] = "int8_t" 
    elseif ( qtype == "I2" ) then 
      qtypes[#qtypes+1] = "int16_t" 
    elseif ( qtype == "I4" ) then 
      qtypes[#qtypes+1] = "int32_t" 
    elseif ( qtype == "I8" ) then 
      qtypes[#qtypes+1] = "int64_t" 
    elseif ( qtype == "F4" ) then 
      qtypes[#qtypes+1] = "float" 
    elseif ( qtype == "F8" ) then 
      qtypes[#qtypes+1] = "double" 
    elseif ( qtype == "SC" ) then 
      qtypes[#qtypes+1] = "char:" .. tostring(v:width())
    else
      error("qtype of vector not supported -> " .. qtype)
    end
    n = n + 1
  end
  assert(( n >= 1 ) and ( n <= 4 )) -- cannot group count > 4 keys at a time
  configs.qtypes = qtypes
  return configs
end
return make_configs
