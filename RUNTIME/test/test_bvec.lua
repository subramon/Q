require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ;
local qconsts = require 'Q/UTILS/lua/q_consts' 
-- for k, v in pairs(vec) do print(k, v) end 

local tests = {} 
local y 
local M
local exp_file_size

tests.t1 = function()
  -- create a nascent vector a bit at a time
  y = Vector.new('B1', qconsts.Q_DATA_DIR)
  local num_elements = 100000
  for j = 1, num_elements do 
    local bval = nil
    if ( ( j % 2 ) == 0 ) then bval = true else bval = false end
    local s1 = Scalar.new(bval, "B1")
    y:put1(s1)
  end
  y:eov()
  M = loadstring(y:meta())(); 
  y:persist()
  exp_file_size = (math.ceil(num_elements/64.0) * 64) /8
  -- print("file_name of B1 = ", M.file_name)
  -- print("num elements = ", M.num_elements)
  -- print("exp_file_size = ", exp_file_size)
  -- print("act_file_size = ", plpath.getsize(M.file_name))
  assert(exp_file_size == plpath.getsize(M.file_name))

  -- MANUAL: Do od of file and check that it is okay
  print("Successfully completed test t1")
end
--=========================

-- Test bufferred puts, when multiple of 8
tests.t2 = function()
  local buf = cmem.new(8*4, "I4", "buf t2")
  buf:set(2147483647, "I4")
  y = Vector.new('B1', qconsts.Q_DATA_DIR)
  local num_elements = 9
  for j = 1, num_elements do 
    y:put_chunk(buf, 32)
  end
  y:eov()
  M = loadstring(y:meta())(); 
  y:persist()
  exp_file_size = math.ceil(( num_elements * 32 /8.0 ) / 8.0) * 8
  assert(exp_file_size == plpath.getsize(M.file_name))
  -- MANUAL: Do od of file and check that it is okay
  print("Successfully completed test t2")
end
--=========================

-- create a 1 bit vector. should be size 8 bytes
tests.t3 = function()
  y = Vector.new('B1', qconsts.Q_DATA_DIR)
  local num_elements = 100000
  y:put1(Scalar.new(true, "B1"))
  y:eov()
  M = loadstring(y:meta())(); 
  print("file_name of B1 = ", M.file_name)
  y:persist()
  assert(8 == plpath.getsize(M.file_name))
  print("Successfully completed test t3")
end
--==============================

-- Test bufferred puts, when sizes = 1, 2, 3, ... 32, 1, 2, ...
-- First test when < 64 
tests.t4 = function()
  local buf = cmem.new(9*4, "I4", "buf t2")
  buf:set(2147483647, "I4")
  y = Vector.new('B1', qconsts.Q_DATA_DIR)
  local num_elements = 9
  local buf_size = 1
  for j = 1, num_elements do 
    y:put_chunk(buf, buf_size)
    buf_size = buf_size + 1
    if ( buf_size > 32 ) then buf_size = 1 end 
  end
  y:eov()
  M = loadstring(y:meta())(); 
  y:persist()
  exp_file_size = (math.ceil(num_elements/64.0) * 64) /8
  -- print("file_name of B1 = ", M.file_name)
  -- print("num elements = ", M.num_elements)
  -- print("exp_file_size = ", exp_file_size)
  -- print("act_file_size = ", plpath.getsize(M.file_name))
  assert(exp_file_size == plpath.getsize(M.file_name))
  print("Successfully completed test t4")
end

-- Second test when > 64 
tests.t5 = function()
  local buf = cmem.new(17*4, "I4", "buf t2")
  buf:set(2147483647, "I4")
  y = Vector.new('B1', qconsts.Q_DATA_DIR)
  local num_elements = 17
  local buf_size = 1
  local num_bits = 1
  for j = 1, num_elements do 
    y:put_chunk(buf, buf_size)
    num_bits = num_bits + buf_size 
    buf_size = buf_size + 1
    if ( buf_size > 32 ) then buf_size = 1 end 
  end
  y:eov()
  M = loadstring(y:meta())(); 
  y:persist()
  exp_file_size = (math.ceil(num_bits/64.0) * 64) /8
  print("file_name of B1 = ", M.file_name)
  print("num elements = ", M.num_elements)
  print("exp_file_size = ", exp_file_size)
  print("act_file_size = ", plpath.getsize(M.file_name))
  assert(exp_file_size == plpath.getsize(M.file_name))
  print("Successfully completed test t5")
end
--==========================

return tests
