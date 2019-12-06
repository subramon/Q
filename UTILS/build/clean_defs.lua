-- Given an input file
-- 1) Remove any line that starts with #include
-- 2) If incs provided, Run the rest through the C pre-processor 
-- 3)  Remove any line that starts with # This gets rid of 
--    #ifdef
--    #ifndef
--    #endif
--    #define
-- 4) Return a string with the above

local exec_and_capture_stdout = require 'Q/UTILS/lua/exec_and_capture_stdout'

local function clean_defs(
  file,
  incs
  )
  assert(type(file) == "string")
  --[[ TODO P1: Why were we using cpp? 
  local cmd = string.format(
    "cat %s | grep -v q_incs | cpp %s %s | grep -v '^#'", 
    file, file, incs)
    --]]
  local cmd
  if ( incs ) then
    assert(type(incs) == "string")
    cmd = string.format( "cat %s|grep -v q_incs |cpp %s %s|grep -v '^#'",
      file, file, incs)
  else
    cmd = string.format( "cat %s | grep -v q_incs | grep -v '^#'", file)
  end
  local  rslt = exec_and_capture_stdout(cmd)
  -- check that you do not get back empty string 
  local chk = string.gsub(rslt, "%s", "")
  assert(#chk > 0) 
  -- now get the #define statements
  cmd = string.format("grep \"^#define\" %s | grep -v __ ", file)
  local  defines = exec_and_capture_stdout(cmd)
  --==============
  return rslt, defines
end
return clean_defs
-- x = clean_defs("/home/subramon/WORK/Q/RUNTIME/VCTR/inc/core_vec_struct.h", "-I../../../UTILS/inc/")
-- print(x)
