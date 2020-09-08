local type_map = {}
local original_type = type

local function register_type(obj, name)
  -- make sure that this name has not been used before
  for k, v in pairs(type_map) do 
    assert(v ~= name)
  end
  type_map[obj] = name
  return true
end

-- Luacheck complains: "setting read-only global variable type"
-- However, we have to let this pass since we are re-defining 
-- the function type to be this function shown below
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
