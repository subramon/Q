local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local Vector  = require 'libvec'  
local Scalar  = require 'libsclr'  
local cmem    = require 'libcmem'  
local lVector = require 'Q/RUNTIME/lua/lVector'
local fns = require 'Q/RUNTIME/test/generate_csv'
local ffi = require 'ffi'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local qc     = require 'Q/UTILS/lua/q_core'
local c_to_txt     = require 'Q/UTILS/lua/C_to_txt'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/RUNTIME/test/"
assert(plpath.isdir(path_to_here))
require 'Q/UTILS/lua/strict'

local v
local ival
local databuf
local x
local T
local md -- meta data

-- testcases for lVector ( materialized vector )
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
  -- Changed the string comparison logic as "nn_file_name" and "base_file_name" were having absolute path in result file 
  -- where as in src_comparison file we were having base name
  local s1 = dofile(f1)
  local s2 = dofile(f2)
  for i, _ in pairs(s1) do
    if i ~= "nn_file_name" and i ~= "base_file_name" then
      assert(s1[i] == s2[i], s1[i] .. " " .. s2[i])
    end
  end
end
--=========================

--====== Testing materialized vector
tests.t1 = function()

  local num_values = 10
  local qtype = "I4"
  -- generating .bin files required for materialized vector
  qc.generate_bin(num_values, qtype, path_to_here .. "_in1_I4.bin", "linear" )
  qtype = "B1"
  qc.generate_bin(num_values, qtype, path_to_here .. "_nn_in1.bin", nil)
  
  x = lVector(
  { qtype = "I4", file_name = path_to_here .. "_in1_I4.bin", nn_file_name = path_to_here .. "_nn_in1.bin"})
  assert(x:check())
  assert(x:has_nulls())
  assert(x:fldtype() == "I4")
  pr_meta(x, path_to_here .. "_t1_meta_data.csv")
  compare(path_to_here .. "_t1_meta_data.csv", path_to_here .. "in1_meta_data.csv")
  local len, base_data, nn_data = x:chunk(0)
  assert(type(base_data) == "CMEM")
  assert(base_data:is_foreign() == true)
  assert(base_data:fldtype() == "I4")

  assert(len == 10)

  assert(type(nn_data) == "CMEM")
  assert(nn_data:is_foreign() == true)
  assert(nn_data:fldtype() == "B1")
  print("Successfully completed test t1")
  collectgarbage() -- causes a seg fault in cmem_free()

  --plfile.delete(path_to_here .. "/_in1_I4.bin")
  --plfile.delete(path_to_here .. "/_nn_in1.bin")
end
--=========

tests.t2 = function()

  local num_values = 10
  local qtype = "I4"
  -- generating .bin files required for materialized vector
  qc.generate_bin(num_values,qtype, path_to_here .. "_in2_I4.bin", "linear" )
  
  x = lVector( { qtype = "I4", file_name = path_to_here .. "_in2_I4.bin"})
  assert(x:check())
  local n = x:num_elements()
  assert(n == 10)
  --=========
  local len, base_data, nn_data = x:chunk(0)
  assert(type(len) == "number")
  assert(len == 10)
  assert(base_data)
  assert(type(base_data) == "CMEM")
  assert(nn_data == nil)

  for i = 1, len do
    local sval = x:get_one(i-1)
    assert(sval == Scalar.new(i*10, "I4"))
  end
  assert(not nn_data)
  assert(len == 10)
  --=========
  len, base_data, nn_data = x:chunk(100)
  assert(not base_data)
  assert(not nn_data)
  print("Successfully completed test t2")
  --plfile.delete(path_to_here .. "/in2_I4.csv")
  --plfile.delete(path_to_here .. "/_in2_I4.bin")
  --=========
end

--====== Testing materialized vector for SC
tests.t3 = function()
  print("Testing materialized vector for SC")
  plfile.copy(path_to_here .. "SC1.bin", path_to_here .. "_SC1.bin")
  local full_file = path_to_here .. "/_SC1.bin"
  assert(plpath.isfile(full_file), "file not found")
  x = lVector( { qtype = "SC", width = 8, file_name = full_file})
  T = x:meta()
  -- local k, v
  local num_aux = 0
  for k, v in pairs(T.aux)  do num_aux = num_aux + 1 end 
  assert(not T.nn) 
  assert(num_aux == 0) -- TODO WHY DO WE HAVE AUX DATA HERE?
  --===========================================
  print("Successfully completed test t3")
end

tests.t4 = function()
  
  local num_values = 10
  local qtype = "I4"
  -- generating .bin files required for materialized vector
  qc.generate_bin(num_values,qtype, path_to_here .. "_in3_I4.bin", "linear" )
  
  -- testing setting and getting of meta data 
  local x = lVector( { qtype = "I4", file_name = path_to_here .. "_in3_I4.bin"})
  x:set_meta("rand_key", "rand val")
  v = x:get_meta("rand_key")
  assert(v == "rand val")
  x:set_meta("rand_key", "some other rand val")
  v = x:get_meta("rand_key")
  assert(v == "some other rand val")
  --plfile.delete("./_meta_data.csv")
  pr_meta(x, path_to_here .. "_t4_meta_data.csv")
  compare(path_to_here .. "_t4_meta_data.csv", path_to_here .. "in4_meta_data.csv")

  print("Successfully completed test t4")
  --plfile.delete(path_to_here .. "/in3_I4.csv")
  --plfile.delete(path_to_here .. "/_in3_I4.bin")
end

--==============================================
tests.t5 = function()
    local num_values = 10
  local qtype = "I4"
  -- generating .bin files required for materialized vector
  qc.generate_bin(num_values,qtype, path_to_here .. "_in4_I4.bin", "linear" )
  
  -- testing setting and getting of meta data with a Scalar
  local x = lVector( { qtype = "I4", file_name = path_to_here .. "_in4_I4.bin"})
  local s = Scalar.new(1000, "I8")
  x:set_meta("rand scalar key", s)
  v = x:get_meta("rand scalar key")
  assert(v == s)
  print("Successfully completed test t5")
  --plfile.delete(path_to_here .. "/in4_I4.csv")
  --plfile.delete(path_to_here .. "/_in4_I4.bin")
end
return tests
