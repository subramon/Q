local cutils  = require 'libcutils'
local Q = require 'Q'
local cVector = require 'libvctr'
local n = 100
local x, y, z = cutils.mem_info()
print(0, y)
local dummy = Q.const({val= 1, qtype = "I8", len = 1024})
for i = 1, n do 
   local a = Q.const({val= 1, qtype = "I8", len = 1048576})
   a:set_name("aaaaa")
   local uqid = a:uqid()
   print("after creation of " .. tostring(uqid))
   a:eval(); 
   print("after evaltion of " .. tostring(uqid))
   cVector.hogs("mem")
   cVector.hogs("dsk")
   print("4444")
   print("=================")
   a = nil
   collectgarbage();
   print("after deletion of " .. tostring(uqid))
   cVector.hogs("mem")
   cVector.hogs("dsk")
   local x, y, z = cutils.mem_info()
   print(i, y)
   dummy:nop()
   print("=================")
 end

