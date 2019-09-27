-- Given an input file
-- 1) Remove any line that starts with #include
-- 2) Run the rest through the C pre-processor
-- 3)  Remove any line that starts with # This gets rid of 
--    #ifdef
--    #ifndef
--    #endif
-- 4) Return a string with the above
local function clean_defs(file, incs)
   local cmd = string.format("cpp %s %s | grep -v '^#'", file, incs)
   local handle = io.popen(cmd)
   local res = handle:read("*a")
   handle:close()
   return res
end
return clean_defs
-- x = clean_defs("/home/subramon/WORK/Q/RUNTIME/VCTR/inc/core_vec_struct.h", "-I../../../UTILS/inc/")
-- print(x)
