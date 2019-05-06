-- FUNCTIONAL 
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi      = require 'Q/UTILS/lua/q_ffi'
local qc       = require 'Q/UTILS/lua/q_core'
local dbg      = require 'Q/UTILS/lua/debugger'
local Vector   = require 'Q/RUNTIME/COLUMN/code/lua/c_Vector'
os.execute("rm -f _*")

local x 
local idx 
local addr
local len  = 1
local vec_len = 64*qconsts.chunk_size+3
local addr = ffi.malloc(len * qconsts.qtypes["I4"].width)
addr = ffi.cast("int32_t *", addr)

local sz_after = 32


local status
local x
for iter = 1, 100 do
  x = Vector({ field_type = "I4", is_nascent = true})
  for i = 1, vec_len do 
    local after = ffi.new("char[?]", sz_after)
    addr[0] = i*10
    local before = tonumber(addr[0])
    x:set(addr, nil, len)
    status = x:check(); assert(status == 0)
    local chk_addr, chk_len = x:get(i-1, 1)
    status = x:check(); assert(status == 0)
    assert(chk_len == 1)
    assert(chk_addr ~= nil )
    local after = tonumber(addr[0])
    chk_addr = ffi.cast("int32_t *", chk_addr)
    local get_val = tonumber(chk_addr[0])
    print("L: ",  i, before, after, get_val)
    assert(before == get_val)

    -- if ( ( i % (16*1024) ) == 0 ) then print("W: ", i) end
  end
  x:eov()
  print("=== Created vector ===", iter)
  local T = x:meta()
  -- print(T.file_name)
  assert(plpath.isfile(tostring(T.file_name)))

  if ( iter == 1 ) then 
    local command = "cp " ..T.file_name .. " _xxx.bin"
    os.execute(command)
  end

    local num_strange = 0
  for i = 1, vec_len do
    local addr, len = x:get(i-1, 1)
    local addr = ffi.cast("int32_t *", addr)
    if  ( addr == ffi.NULL ) or ( tonumber(addr[0]) ~= i*10) then 
      num_strange = num_strange + 1
      --[[
      io.write("STRANGE  "); 
      io.write(i, "     ", tonumber(addr[0]), "    ", i*10)
      print("============="); 
      --]]
    end
    --- if ( ( i % (16*1024) ) == 0 ) then print("R: ", i) end
  end
    if ( num_strange > 0 ) then print ("Num errors ", num_strange) end
  if ( ( iter %  8 ) == 0 ) then
    print("GARBAGE COLLECTION")
    collectgarbage()
  end
end
--====================================
os.exit()

assert(plpath.isfile("_xxx.bin"))

-- check file deleted on garbage collection
x:destroy()

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
