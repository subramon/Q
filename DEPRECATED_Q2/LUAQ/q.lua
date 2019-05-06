dofile "../LUAQ/parseq.lua"
function q(qcommand)
  --==== Parse the command, unless it starts with "JSON:"
  assert(tostring(qcommand))
  alt_qcommand = string.gsub(qcommand, "^JSON:", "") 
  local x = nil
  if ( alt_qcommand == qcommand ) then 
    json_com_as_tbl = assert(parseq(qcommand))
  else
    json_com_as_tbl = assert(json:decode(alt_qcommand))
  end
  -- local z = json:encode_pretty(json_com_as_tbl); print(" json = ", z)
  local verb = json_com_as_tbl.verb
  -- print("parser completed")
  -- print("START: chk_" .. verb)
  local chk_fn = assert(_G["chk_"..verb], "MISSING: chk for " .. verb)
  assert(chk_fn(json_com_as_tbl), "Failed chk for " .. verb)
  -- print("STOP: chk_" .. verb)
  -- execution, hand off to C for the most part
  -- print("START: exec_" .. verb)
  local exec_fn = assert(_G["exec_"..verb], "MISSING: exec_" .. verb)
  local retval1 = assert(exec_fn(json_com_as_tbl), "ERROR: exec_" .. verb)
  -- print("STOP: exec_" .. verb)
  -- it is the responsiblity of exec_* to modify json_com_as_tbl 
  -- so that it contains information needed for update to do its job.

  -- update meta data. We wil return a JSON string that contains 
  -- everything the caller needs to know about what happened. 
  -- print("START: update_" .. verb)
  local update_fn = assert(_G["update_"..verb], "MISSING: update for " .. verb)
  local retval2 = assert(update_fn(json_com_as_tbl), "ERROR: update_" .. verb)
  -- print("STOP : update_" .. verb)
  if type(retval1) == "table" then 
    return retval1
  else
    return retval2
  end
end
