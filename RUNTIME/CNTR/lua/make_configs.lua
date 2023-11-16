-- make the configs needed by make_kc_so to generate C custom code
-- for key counter
local function make_configs(label, vecs)
  local configs = {}
  configs.label = label
  local n = 0
  local key_types = {}
  for k, v in ipairs(vecs) do 
    assert(type(v) == "lVector")
    --==============================
    assert(v:max_num_in_chunk() == vecs[1]:max_num_in_chunk())
    assert(v:is_eov() == vecs[1]:is_eov())
    if ( v:is_eov() ) then 
      assert(v:num_elements() == vecs[1]:num_elements())
    end 
    --==============================
    local qtype = v:qtype()
    if ( qtype == "I1" ) then 
      key_types[#key_types+1] = "int8_t" 
    elseif ( qtype == "I2" ) then 
      key_types[#key_types+1] = "int16_t" 
    elseif ( qtype == "I4" ) then 
      key_types[#key_types+1] = "int32_t" 
    elseif ( qtype == "I8" ) then 
      key_types[#key_types+1] = "int64_t" 
    elseif ( qtype == "UI1" ) then 
      key_types[#key_types+1] = "uint8_t" 
    elseif ( qtype == "UI2" ) then 
      key_types[#key_types+1] = "uint16_t" 
    elseif ( qtype == "UI4" ) then 
      key_types[#key_types+1] = "uint32_t" 
    elseif ( qtype == "UI8" ) then 
      key_types[#key_types+1] = "uint64_t" 
    elseif ( qtype == "F4" ) then 
      key_types[#key_types+1] = "float" 
    elseif ( qtype == "F8" ) then 
      key_types[#key_types+1] = "double" 
    elseif ( qtype == "SC" ) then 
      key_types[#key_types+1] = "char:" .. tostring(v:width())
    else
      error("qtype of vector not supported -> " .. qtype)
    end
    n = n + 1
  end
  assert(( n >= 1 ) and ( n <= 4 )) -- cannot group count > 4 keys at a time
  configs.key_types = key_types
  return configs
end
return make_configs
