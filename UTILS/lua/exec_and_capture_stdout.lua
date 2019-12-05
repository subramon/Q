local function exec_and_capture_stdout(cmd)
  local handle = io.popen(cmd)
  if ( handle == nil ) then return nil end 
  local rslt = handle:read("*a")
  handle:close()
  return rslt
end
return exec_and_capture_stdout
