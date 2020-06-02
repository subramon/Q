-- These functions are used to exclude things from being saved
local function should_save(k,v)
  if type(v) == "cdata"     then return false end
  if type(v) == "coroutine" then return false end
  if type(v) == "function"  then return false end
  if type(v) == "userdata"  then return false end
  -- TODO Not sure what the following are doing
  if k == "_G" then return false end
  if k == "_VERSION" then return false end
  if k == "arg" then return false end
  if k == "bit" then return false end
  if k == "coroutine" then return false end
  if k == "debug" then return false end
  if k == "ffi" then return false end
  if k == "io" then return false end
  if k == "jit" then return false end
  if k == "lfs" then return false end
  if k == "libs" then return false end
  if k == "lVector" then return false end
  if k == "math" then return false end
  if k == "package" then return false end
  if k == "posix" then return false end
  if k == "q" then return false end
  if k == "q_core" then return false end
  if k == "os" then return false end
  if k == "Q" then return false end
  if k == "string" then return false end
  if k == "table" then return false end
  if k == "utils" then return false end
  if string.match(k, "^g_") then return false end
  return true
end
return should_save
