local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local Vector  = require 'libvec'  
local Scalar  = require 'libsclr'  
local cmem    = require 'libcmem'  
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/RUNTIME/test/"
assert(plpath.isdir(path_to_here))
require 'Q/UTILS/lua/strict'

local v
local ival
local databuf
local x
local T
local md -- meta data 

-- testcases for lVector ( nascent vector )
local tests = {} 

--===================
local function pr_meta(x, file_name)
  local T = x:meta()
  local temp = io.output() -- this is for debugger to work 
  io.output(file_name)
  io.write(" return { ")
  for k1, v1 in pairs(T) do 
    for k2, v2 in pairs(v1) do 
      io.write(k1 .. "_" ..  k2 .. " = \"" .. tostring(v2) .. "\",")
      io.write("\n")
    end
  end
  io.write(" } ")
  io.close()
  io.output(temp) -- this is for debugger to work 
  return T
end
--=========================
local function compare(f1, f2)
  local s1 = plfile.read(f1)
  local s2 = plfile.read(f2)
  assert(s1 == s2, "mismatch in " .. f1 .. " and " .. f2)
end
--=========================


--====== Testing nascent vector
tests.t1 = function()
  print("Creating nascent vector")
  x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local num_elements = 1024
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size, "I4", "base")
  local b3 = get_ptr(base_data, "I4")
  for i = 1, num_elements do
    b3[i-1] = i*10
  end
  x:put_chunk(base_data, nil, num_elements)
  assert(x:check())
  x:eov()
  assert(x:check())
  pr_meta(x, "_xxx")
  print("Successfully completed test t1")
end

--====== Testing nascent vector with scalars
tests.t2 = function()
  x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local num_elements = 1024
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size, "I4", "t2 base")
  for i = 1, num_elements do
    local s1 = Scalar.new(i*11, "I4")
    x:put1(s1)
    assert(x:check())
  end
  x:eov()
  assert(x:check())
  md = pr_meta(x, "_meta_data")
  -- print(">>>> ", md.base.file_name)
  assert(plpath.getsize(md.base.file_name) == num_elements * field_size)
  -- Check that nn_file_name does not exist
  local s = plfile.read("_meta_data")
  local x, y = string.find(s, "nn_file_name")
  assert(not x)
  print("Successfully completed test t2")
end

tests.t3 = function()
  x = lVector( { qtype = "I4", gen = true})
  local num_elements = 1024
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size, "I4", "t3 base")
  local status = pcall(x.put_chunk, base_data, nil, num_elements)
  assert(not status)
  print("Successfully completed test t3")
end

tests.t4 = function()
  print("Testing nascent vector with scalars and nulls")
  x = lVector( { qtype = "I4", gen = true})
  local num_elements = 1024
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size, "I4", "t4 base")
  -- TO DELETE local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, num_elements do
    local s1 = Scalar.new(i*11, "I4")
    local s2
    if ( ( i % 2 ) == 0 ) then
      s2 = Scalar.new(true, "B1")
    else
      s2 = Scalar.new(false, "B1")
    end
    x:put1(s1, s2)
    assert(x:check())
  end
  x:eov()
  assert(x:check())
  md = pr_meta(x, "_meta_data")
  assert(plpath.getsize(md.base.file_name) == num_elements * field_size)
  assert(plpath.getsize(md.nn.file_name) == num_elements / 8)
  -- Check that nn_file_name exists
  local s = plfile.read("_meta_data")
  local x, y = string.find(s, "nn_file_name")
  assert(x)
  print("Successfully completed test t4")
end
--===========================================

--====== Testing nascent vector with generator
tests.t5 = function()
  -- print("Creating nascent vector with generator")
  local gen1 = require 'Q/RUNTIME/test/gen1'
  x = lVector( { qtype = "I4", gen = gen1, has_nulls = false, name = "x"} )
  x:persist(true)

  local x_num_chunks = 10
  local num_chunks = 0
  local chunk_size = qconsts.chunk_size
  for chunk_num = 1, x_num_chunks do 
    local a, b, c = x:chunk(chunk_num-1)
    assert(a)
    if ( b ) then assert(type(b) == "CMEM") end
    assert(c == nil)
    if ( a < chunk_size ) then 
      print("Breaking on chunk", chunk_num); 
      assert(x:is_eov() == true)
      break 
    end
    num_chunks = num_chunks + 1
    assert(a == chunk_size)
    x:check()
  end
    collectgarbage()
  local status = pcall(x.eov)
  assert(not status)
  local T = x:meta()
  assert(plpath.getsize(T.base.file_name) == (num_chunks * chunk_size * 4))
  print("Successfully completed test t5")
end
--===========================================

return tests
