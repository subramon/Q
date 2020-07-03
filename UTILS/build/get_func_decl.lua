-- Given an input file
-- 1) Remove any line that starts with #include
-- 2) If incs provided, Run the rest through the C pre-processor 
-- 3)  Remove any line that starts with # This gets rid of 
--    #ifdef
--    #ifndef
--    #endif
--    #define
-- 4) Return a string with the above

local exec = require 'Q/UTILS/lua/exec_and_capture_stdout'

local function get_func_decl(
  infile,
  incs
  )
  assert(type(infile) == "string")
  --[[ TODO P1: Why were we using cpp? 
  local cmd = string.format(
    "cat %s | grep -v q_incs | cpp %s %s | grep -v '^#'", 
    infile, infile, incs)
    --]]
  local cmd
  if ( incs ) then
    assert(type(incs) == "string")
    cmd = string.format( "cat %s | grep -v q_incs | grep -v q_macros | cpp %s -I%s|grep -v '^#'",
      infile, infile, incs)
  else
    cmd = string.format( "cat %s | grep -v q_incs | grep -v q_macros | grep -v '^#'", infile)
  end
  print(cmd)
  local  rslt = exec(cmd)
  -- check that you do not get back empty string 
  local chk = string.gsub(rslt, "%s", "")
  assert(#chk > 0) 
  -- now get the #define statements
  cmd = string.format("grep \"^#define\" %s | grep -v __ ", infile)
  local  defines = exec(cmd)
  --==============
  return rslt, defines
end
-- return get_func_decl
x = get_func_decl("/Q/RUNTIME/VCTR/inc/core_vec_struct.h", "../inc/")
print(x)
