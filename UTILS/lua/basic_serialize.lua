local function basic_serialize (o)
  if type(o) == "number" or type(o) == "boolean" then
    return tostring(o)
  elseif type(o) == "string" then
    return string.format("%q", o)
  else
    assert(nil)
  end
end
return basic_serialize
