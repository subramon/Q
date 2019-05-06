function parseq(qcommand)
  local json = (loadfile "../../../LUA/json.lua")() -- TODO: FIX
  assert(tostring(qcommand), "qcommand not a string")
  -- make call to C parser
  -- assert(parsed_op, "C parser not hooked up")
  local x, err = assert(qglue.parse(qcommand))
  -- print("qjson   = ", x)
  local t_json = assert(json:decode(x), "Invalud JSON from parser: " .. x)
  return t_json
end
