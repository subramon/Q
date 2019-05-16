-- Given an input file
-- 1) Remove any line that starts with #include
-- 2) Run the rest through the C pre-processor
-- 3)  Remove any line that starts with # This gets rid of 
--    #ifdef
--    #ifndef
--    #endif
-- 4) Return a string with the above
local function clean_defs(file)
   local cmd = string.format(
   "cat %s | grep -v '#include'| cpp | grep -v '^#'", file)
   local handle = io.popen(cmd)
   local res = handle:read("*a")
   handle:close()
   return res
end
return clean_defs
