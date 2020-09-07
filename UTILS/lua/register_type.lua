local type_map = {}
local original_type = type

local function register_type(obj, typename)
  assert(type(obj) == "table")
  assert(type(typename) == "string")
  assert(#typename > 0)
  -- cannot use an existing typename
  for k, v in pairs(type_map) do assert(v ~= typename) end

  type_map[obj] = typename
  return true
end

-- TODO P2 Luacheck complains: setting read-only global variable type
type = function(obj)
  print("obj = ", obj)
  print("__index = ", obj.__index)
  local m_table = getmetatable(obj)
  print("m_table = ", m_table)
  if m_table ~= nil then
    print("obj has a meta table")
    local d_type = type_map[m_table]
    print("d_type = ", d_type)
    if d_type ~= nil then
      return d_type
    end
  else
    print("obj does NOT have a meta table")
  end
  print("Returning original type")
  return original_type(obj)
end

return register_type
