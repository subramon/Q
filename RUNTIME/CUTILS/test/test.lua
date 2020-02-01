require 'Q/UTILS/lua/strict'
cutils = require 'libcutils'
local x 
x = cutils.rdtsc()
assert(math.ceil(x) == math.floor(x))
x = cutils.getfiles("../src/", ".*.c$", "only_files")
print("here is what we got")
for k, v in pairs(x) do print(k, v) end
print("=============")
x = cutils.getfiles("../src/")
print("here is what we got")
for k, v in pairs(x) do print(k, v) end
print("=============")
x = cutils.getfiles("../src/", "")
print("here is what we got")
for k, v in pairs(x) do print(k, v) end
print("=============")
x, y = cutils.gettime("../test/test.lua", "last_access")
print("last_access", x, y)
x, y = cutils.gettime("../test/test.lua", "last_mod")
print("last_mod", x, y)
--==============
for i = 1, 1 do 
  local y = cutils.read("../test/test.lua")
end
x = cutils.read("../test/test.lua")
print(x)
--==============
cutils.write("/tmp/_x", "hello world\n");
--==============
cutils.copyfile("/tmp/_x", "/tmp/_y");
--============
-- not being able to negate regexes properly
-- also how do I match special characters. not working as expected
x = cutils.getfiles("/home/subramon/", "", "only_dirs")
print("directoris in $HOME")
for k, v in pairs(x) do print(k, v) end
--==========
cutils.makepath("/tmp/_xxxx")
print("All done")
