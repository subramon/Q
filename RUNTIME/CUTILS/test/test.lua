cutils = require 'libcutils'
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
error("premature")
--==============
for i = 1, 1 do 
  local y = cutils.read("../test/test.lua")
end
x = cutils.read("../test/test.lua")
print(x)
--==============
cutils.write("/tmp/_x", "hello world\n");
