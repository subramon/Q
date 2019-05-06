local type_map = {}
local original_type = type

local function register_type(obj, name)
  type_map[obj] = name
end

type = function(obj)
  local m_table = getmetatable(obj)
  if m_table ~= nil then
    local d_type = type_map[m_table]
    if d_type ~= nil then 
      return d_type 
    end
  end
  return original_type(obj)
end

return register_type
