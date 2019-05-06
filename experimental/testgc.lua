collectgarbage("collect")
print (collectgarbage("count"))

local ffi = require 'ffi'
--local C = terralib.includec("stdlib.h")

ffi.cdef[[
  void *malloc(int);
  void free(void*);
]]

--[[
local Array = function(typ)
    return terra(N : int)
        var r : &typ = [&typ](C.malloc(sizeof(typ) * N))
        return r
    end
end
]]--
--Array = terralib.memoize(Array)
--local intarr = Array(int)
local myfree = function(x)
  print ("FREED!!!")
  ffi.C.free(x)
end

local f = function()
-- local a = {1,2,3}
--  local a = ffi.new("int[?]", 3, {1,2,3})
  local a = ffi.C.malloc(10000)
--  local a = C.malloc(10000)
--  local a = intarr(10000)
--  ffi.gc(a, C.free)
  ffi.gc(a, myfree)
end

local dogc = function()
  print '-----'
  print ("pre: " .. collectgarbage("count"))
  collectgarbage("collect")
  print ("post: " .. collectgarbage("count"))
end

print 'clear slate'
dogc()

for i=1,3 do
  print ('call num ' .. i)
  f()
  dogc()
end
-- TODOs
-- basic GC test with lua objects only DONE!!!

-- TEST memory size of objects Lua vs Terra
require 'globals'
g_chunk_size=nil
g_valid_meta=nil
mk_col = require 'mk_col'
print 'clear slate'
dogc()

print 'calling mk_col repeatedly'
for i=1,10 do
  mk_col({4,3,2,1}, "I4")
  --x = {1,2,3,4}
  dogc()
end