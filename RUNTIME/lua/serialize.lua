local function serialize (o, fp)
  fp = fp or io
  if type(o) == "number" then
    fp:write(o)
  elseif type(o) == "string" then
     fp:write(string.format("%q", o))
  elseif type(o) == "table" then
    fp:write("{\n")
    for k,v in pairs(o) do
      fp:write("  ", k, " = ")
      serialize(v, fp)
      fp:write(",\n")
    end
    fp:write("}\n")
  else
    error("cannot serialize a " .. type(o))
  end
  return true
end
return  serialize
