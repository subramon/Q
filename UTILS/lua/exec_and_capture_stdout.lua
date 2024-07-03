local function exec_and_capture_stdout(cmd)
  assert(type(cmd) == "string")
  assert(#cmd > 0)
  local handle = io.popen(cmd)
  if ( handle == nil ) then 
    print("popen failed for cmd = ", cmd)
    return nil 
  end
  local rslt = handle:read("*a")
  handle:close()
  return rslt
end
return exec_and_capture_stdout
