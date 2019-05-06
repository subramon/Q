-- FUNCTIONAL 
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi      = require 'Q/UTILS/lua/q_ffi'
local dbg      = require 'Q/UTILS/lua/debugger'
local Vector   = require 'Q/RUNTIME/COLUMN/code/lua/Vector'
os.execute("rm -f _*")

local x 
local idx 
local addr
local len  = 1
local vec_len = 64*qconsts.chunk_size+3
local addr = ffi.malloc(len * qconsts.qtypes["I4"].width)
addr = ffi.cast("int32_t *", addr)

local x
for iter = 1, 100 do
  x = Vector({ field_type = "I4", is_nascent = true})
  for i = 1, vec_len do 
    addr[0] = i*10
    x:set(addr, nil, len)
    --- if ( ( i % (16*1024) ) == 0 ) then print("W: ", i) end
  end
  print("=== Created vector ===", iter)
  x:eov()
  x:destroy()
end
local T = x:internals()
local T = x:meta()
for k, v in pairs(T) do print(k, v) end
assert(T.file_name)
assert(plpath.isfile(tostring(T.file_name)))
assert(T.map_len == vec_len * ffi.sizeof("int32_t"))
for i = 1, vec_len do
  local addr = ffi.cast("int32_t *", x:get(i-1, 1))
  assert(addr[0] == i*10)
  --- if ( ( i % (16*1024) ) == 0 ) then print("R: ", i) end
end

local command = "cp " ..T.file_name .. " _xxx.bin"
os.execute(command)
assert(plpath.isfile("_xxx.bin"))

-- check file deleted on garbage collection
x:destroy()
x = nil
collectgarbage()
assert(plpath.isfile(T.file_name)  == false)

-- create a materialized column
y = Vector({ field_type = "I4", is_nascent = false, file_name = "_xxx.bin"})
for i = 1, vec_len do
  local addr = ffi.cast("int32_t *", y:get(i-1, 1))
  assert(addr[0] == i*10)
  -- if ( ( i % (16*1024) ) == 0 ) then print("Ry: ", i) end
end
-- check file NOT deleted on garbage collection if persist set
y:persist()
y = nil
collectgarbage()
assert(plpath.isfile("_xxx.bin"))


print("SUCCESS for ", arg[0])
os.execute("rm -f _*")
