-- These functions are used to exclude things from being saved
-- TODO P3 Need to study difference between l and g functions
local fns = {}
fns.l =  function (k,v)
  if type(v) == "function" then return true end
  if type(v) == "cdata" then return true end
  return false
end

fns.g = function (k,v)
  if type(v) == "function" then return true end
  if type(v) == "cdata" then return true end
  if k == "coroutine" then return true end
  if k == "io" then return true end
  if k == "utils" then return true end
  if k == "Q" then return true end
  if k == "lVector" then return true end
  if k == "Vector" then return true end
  if k == "ffi" then return true end
  if k == "package" then return true end
  if k == "_G" then return true end
  if k == "jit" then return true end
  if k == "lfs" then return true end
  if k == "posix" then return true end
  if k == "q_core" then return true end
  if k == "q" then return true end
  if k == "math" then return true end
  if k == "table" then return true end
  if k == "os" then return true end
  if k == "string" then return true end
  if k == "debug" then return true end
  if k == "_VERSION" then return true end
  if k == "libs" then return true end
  if string.match(k, "^g_") then return true end
  if k == "bit" then return true end
  if k == "arg" then return true end
  if type(v) == "userdata" then return true end
  return false
end

return fns
