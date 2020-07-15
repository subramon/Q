require 'Q/UTILS/lua/strict'
local is_in = require 'Q/UTILS/lua/is_in'
cutils = require 'libcutils'
local x, y, sec, nsec
x = cutils.rdtsc()
assert(math.ceil(x) == math.floor(x))

x = cutils.getfiles("../src/", ".*.c$", "only_files")
assert(type(x) == "table")
for _, v in ipairs(x) do assert(type(v) == "string") end 
-- print("here is what we got")
-- for k, v in pairs(x) do print(k, v) end
-- print("=============")

x = cutils.getfiles("../src/")
assert(type(x) == "table")
for _, v in ipairs(x) do assert(type(v) == "string") end 
-- print("here is what we got")
-- for k, v in pairs(x) do print(k, v) end
-- print("=============")

x = cutils.getfiles("../src/", "")
assert(type(x) == "table")
for _, v in ipairs(x) do assert(type(v) == "string") end 
-- print("here is what we got")
-- for k, v in pairs(x) do print(k, v) end
-- print("=============")
sec, nsec = cutils.gettime("../test/test.lua", "last_access")
-- print("last_access", x, y)
sec, nsec = cutils.gettime("../test/test.lua", "last_mod")
-- print("last_mod", x, y)
--==============
for i = 1, 110 do 
  local z = cutils.read("../test/test.lua")
  assert(type(z) == "string")
  assert(#z > 0)
end
--==============
cutils.write("/tmp/_x", "hello world\n")
y = cutils.read("/tmp/_x")
assert(y == "hello world\n")
--==============
cutils.copyfile("/tmp/_x", "/tmp/_y");
y = cutils.read("/tmp/_y")
assert(y == "hello world\n")
--============
-- not being able to negate regexes properly
-- also how do I match special characters. not working as expected
x = cutils.getfiles("..", "", "only_dirs")
assert(type(x) == "table")
for _, v in ipairs(x) do 
  assert(is_in(v, { "test", "src" } ))
end
--==========
cutils.makepath("/tmp/_xxxx")
assert(cutils.isdir("/tmp/_xxxx"))

print("All done")
