-- FUNCTIONAL 
local plpath = require 'pl.path'
local ffi      = require 'lua/q_ffi'
local Vector   = require 'lua/c_Vector_stripped'
os.execute("rm -f _*")

local len  = 1

-- Number of elements in vector (4194304)
local vec_len = 64*64*1024

-- Creating chunk for a single element of type int32_t
element_fld_size = 4
local addr = ffi.malloc(element_fld_size)
addr = ffi.cast("int32_t *", addr)

local status
local x
for iter = 1, 100 do
  -- Create vector instance
  x = Vector({ field_size = element_fld_size})
  for i = 1, vec_len do 
    addr[0] = i*10
    -- Set value to vector
    x:set(addr, len)
  end
  print("=== Created vector ===", iter)

  -- Calling garbage collection explicitly for testing purpose
  --if ( ( iter %  8 ) == 0 ) then
  --  print("GARBAGE COLLECTION")
  --  collectgarbage()
  --end
end
--====================================
os.exit()
