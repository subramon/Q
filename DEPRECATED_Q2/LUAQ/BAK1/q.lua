dofile "parseq.lua"
function q(qcommand)
  --==== Parse the command, unless it starts with "JSON:"
  print("qcommand = ", qcommand)
  assert(tostring(qcommand))
  alt_qcommand = string.gsub(qcommand, "^JSON:", "") 
  local x = nil
  if ( alt_qcommand == qcommand ) then 
    json_com_as_tbl = assert(parseq(qcommand))
  else
    json_com_as_tbl = assert(json:decode(alt_qcommand))
  end
  -- print("parser completed")
  --====== perform meta data checks
  local verb = assert(json_com_as_tbl.verb)
  name_chk_fn = "chk_" .. verb
  local chk_fn = assert(_G[name_chk_fn], "Cannot find " .. name_chk_fn )
  local _ret = nil
  print("name_chk-fn = ", name_chk_fn)
  if ( _G[name_chk_fn] ~= nil ) then 
    _ret = _G[name_chk_fn](json_com_as_tbl)
  end
  print("111111")
  -- execution, hand off to C for the most part
  local exec_fn = "exec_" .. verb;
  print("About to execute: exec_fn = ", exec_fn)
  local M = nil
  if ( _G[exec_fn] ~= nil ) then 
    M = _G[exec_fn](json_com_as_tbl, _ret)
    print("Executed: exec_fn = ", exec_fn)
    -- for k, v in pairs(json_com_as_tbl) do print(k, v) end
    if ( json_com_as_tbl.no_updates ) then 
      if ( M == nil ) then
        return "{}"
      else
        return json:encode(M) 
      end
    else
      assert(M, "ERROR")
    end
  else 
    M = json_com_as_tbl
  end
  -- if there are no updates, we stop right here. If there are updates, 
  -- it is the responsiblity of exec_* to return a table which contains 
  -- the information needed for update_* to do its job.

  -- update meta data. We wil return a JSON string that contains 
  -- everything the caller needs to know about what happened. 
  local update_fn = "update_" .. json_com_as_tbl.verb;
  print("About to update: update_fn = ", update_fn)
  if (  _G[update_fn] ~= nil ) then 
    name_update_fn = "update_" .. verb
    local update_fn = assert(_G[name_update_fn], "Cannot find " .. name_update_fn )
    assert(M, "ERROR")
    local ret_val = _G[name_update_fn](M)
    if ( ret_val == nil ) then 
      return "{}"
    else
      return json:encode(ret_val) 
    end
  else
    return "{}"
  end
  -- notice, that no matter what, we return a JSON string to the caller
end
