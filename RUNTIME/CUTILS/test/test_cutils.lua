require 'Q/UTILS/lua/strict'
local is_in = require 'Q/UTILS/lua/is_in'
local plpath = require 'pl.path'
local plfile = require 'pl.file'
local cutils = require 'libcutils'

local rootdir = os.getenv("Q_SRC_ROOT")
plpath.isdir(rootdir)

local tests = {}
tests.t1 = function()
  local x, y, sec, nsec
  x = cutils.rdtsc()
  assert(math.ceil(x) == math.floor(x))
  
  local dir = rootdir .. "/RUNTIME/CUTILS/src/"
  x = cutils.getfiles(dir, ".*.c$", "only_files")
  assert(type(x) == "table")
  for _, v in ipairs(x) do assert(type(v) == "string") end 
  -- print("here is what we got")
  -- for k, v in pairs(x) do print(k, v) end
  -- print("=============")
  
  x = cutils.getfiles(dir)
  assert(type(x) == "table")
  for _, v in ipairs(x) do assert(type(v) == "string") end 
  -- print("here is what we got")
  -- for k, v in pairs(x) do print(k, v) end
  -- print("=============")
  
  x = cutils.getfiles(dir, "")
  assert(type(x) == "table")
  for _, v in ipairs(x) do assert(type(v) == "string") end 
  -- print("here is what we got")
  -- for k, v in pairs(x) do print(k, v) end
  -- print("=============")
  assert(plfile.write("/tmp/_xxx.txt", "abcd"))
  sec, nsec = cutils.gettime("/tmp/_xxx.txt", "last_access")
  assert(type(sec) == "number")
  assert(type(nsec) == "number")
  -- print("last_access", x, y)
  sec, nsec = cutils.gettime("/tmp/_xxx.txt", "last_mod")
  -- print("last_mod", x, y)
  assert(type(sec) == "number")
  assert(type(nsec) == "number")
  --==============
  for i = 1, 110 do 
    local chkfile = rootdir .. "/RUNTIME/CUTILS/test/test_cutils.lua"
    local z = cutils.read(chkfile)
    assert(type(z) == "string")
    assert(#z > 0)
  end
  --==============
  cutils.write("/tmp/_x", "hello world\n")
  y = cutils.read("/tmp/_x")
  assert(y == "hello world\n")
  --==============
  assert(cutils.copyfile("/tmp/_x", "/tmp/_y"))
  y = cutils.read("/tmp/_y")
  assert(y == "hello world\n")
  --============
  -- not being able to negate regexes properly
  -- also how do I match special characters. not working as expected
  dir = rootdir .. "/RUNTIME/CUTILS/"
  x = cutils.getfiles(dir, "", "only_dirs")
  assert(type(x) == "table")
  for _, v in ipairs(x) do 
    assert(is_in(v, { "test", "src" } ))
  end
  --==========
  cutils.makepath("/tmp/_xxxx")
  assert(cutils.isdir("/tmp/_xxxx"))
  
  print("Test t1 succeeded")
end
-- tests.t1()
return tests
