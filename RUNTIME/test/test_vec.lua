local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'
local gen_bin = require 'Q/RUNTIME/test/generate_bin'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
require 'Q/UTILS/lua/strict'

local M
local is_memo
local chunk_size = qconsts.chunk_size
local rslt

local tests = {} 
--
tests.t1 = function()
  print("Starting test t1")
  local buf = cmem.new(4096, "I4", "t1 buffer")
  local infile = '_in1_I4.bin'
  local num_values = 10
  local q_type = "I4"
  -- generating .bin files required for materialized vector
  qc.generate_bin(num_values, q_type, infile, "linear" )
 
  assert(plpath.isfile(infile), "Create the input files")
  local y = Vector.new('I4', qconsts.Q_DATA_DIR, infile, false)
  local filesize = plpath.getsize(infile)
  y:persist(true)
  local ylen = Vector.num_elements(y)
  local ylen2 = y:num_elements()
  assert(ylen == ylen2)
  assert(ylen*4 == filesize)
  assert(y:check())
  local a, b = y:eov()
  assert(a) -- unnecessary eov is not an erro
  local z = y:meta()
  -- print(z)
  M = loadstring(z)
  -- print(M)
  local X = M()
  -- print(X)
  M = loadstring(y:meta())()
  -- print(M)
  for k, v in pairs(M) do 
    if ( k == "is_memo") then assert(v == true) end
    if ( k == "field_type") then assert(v == "I4") end
    if ( k == "chunk_num") then assert(v == 0) end
    if ( k == "num_in_chunk") then assert(v == 0) end
    if ( k == "file_name") then assert(v == "_in1_I4.bin") end
    if ( k == "is_persist") then assert(v == true) end 
    if ( k == "is_nascent") then assert(v == false) end 
    if ( k == "is_write") then assert(v == false) end 
    if ( k == "chunk_size") then assert(v == qconsts.chunk_size) end 
  end
  y = nil
  collectgarbage()
  print("Successfully completed test t1")
end

-- try to modify a vector created as read only. Should fail
tests.t2 = function()
  local num_values = 10
  local q_type = "I4"
  -- generating .bin files required for materialized vector
  qc.generate_bin(num_values, q_type, "_in1_I4.bin", "linear" )
  assert(plpath.isfile("_in1_I4.bin"))
  local y = Vector.new('I4', qconsts.Q_DATA_DIR, '_in1_I4.bin')
  y:persist(true)
  local s = Scalar.new(123, "I4")
  local status = y:set(s, 0)
  assert(status == nil)
  print("Successfully completed test t2")
end
--==============================================

-- try to modify a vector created as read only by eov. Should fail
tests.t3 = function()
  local y = Vector.new('I4', qconsts.Q_DATA_DIR)
  local s = Scalar.new(123, "I4")
  local status = y:put1(s)
  assert(status)
  status = y:eov(true)
  assert(status)
  status = y:set(s, 0)
  assert(status == nil)
  print("Successfully completed test t3")
end
--==============================================

-- can memo a vector until it hits chunk size. then must fail
tests.t4 = function()
  local y = Vector.new('I4', qconsts.Q_DATA_DIR)
  local s = Scalar.new(123, "I4")
  for i = 1, chunk_size do 
    local status = y:put1(s)
    assert(status)
    if ( ( i % 2 ) == 0 ) then is_memo = true else is_memo = false end
    status = y:memo(is_memo)
    assert(status)
  end
  local status = y:put1(s)
  assert(status)
  status = y:memo(is_memo)
  assert(status == nil)
  print("Successfully completed test t4")
end
--==============================================

-- num_in_chunk should increase steadily and then reset after chunk_size
tests.t5 = function()
  local y = Vector.new('I4', qconsts.Q_DATA_DIR)
  local s = Scalar.new(123, "I4")
  local chunk_size = qconsts.chunk_size
  for i = 1, chunk_size do 
    local status = y:put1(s)
    assert(status)
    M = loadstring(y:meta())(); 
    assert(M.num_in_chunk == i)
    assert(M.chunk_num == 0)
  end
  local status = y:put1(s)
  M = loadstring(y:meta())();
  print(M.num_in_chunk) 
  assert(M.num_in_chunk == 1)
  assert(M.chunk_num == 1)
  print("Successfully completed test t5")
end
--==============================================

-- Can get current chunk num but cannot get previous 
-- ret_len should be number of elements in chunk
tests.t6 = function()
  local orig_ret_addr = nil
  local s = Scalar.new(123, "I4")
  local y = Vector.new('I4', qconsts.Q_DATA_DIR)
  for i = 1, chunk_size do 
    local status = y:put1(s)
    assert(status)
    local ret_cmem, ret_len = y:get_chunk(0);
    assert(ret_cmem);
    assert(ret_len == i)
    if ( i == 1 ) then 
      orig_ret_addr = get_ptr(ret_cmem, "I4")
    else
      local ret_addr = get_ptr(ret_cmem, "I4")
      assert(ret_addr == orig_ret_addr)
    end
  end
  local status = y:put1(s)
  local ret_addr, ret_len = y:get_chunk(0);
  assert(ret_addr)
  -- TODO RAMESH assert(ret_len == chunk_size)
  ret_addr, ret_len = y:get_chunk(1);
  assert(ret_len == 1)
  -- Test get_chunk
  print("Successfully completed test t6")
end
--==============================================

-- create a nascent vector
tests.t7 = function()
  local y = Vector.new('I4', qconsts.Q_DATA_DIR)
  local num_elements = 10000
  for j = 1, num_elements do 
    local s1 = Scalar.new(j, "I4")
    y:put1(s1)
  end
  -- print("writing meta data of nascent vector")
  M = loadstring(y:meta())(); 
  for k, v in pairs(M) do 
    assert(k ~= "file_name")
    if ( k == "is_nascent" ) then assert(v == true) end 
    -- print(k, v) 
  end
  rslt = y:eov()
  assert(rslt)
  -- Second call to eov used to be considered an error. No longer
  rslt = y:eov()
  assert(rslt)
  -- print("writing meta data of persisted vector")
  M = loadstring(y:meta())(); 
  local is_file = false
  for k, v in pairs(M) do 
    if ( k == "file_name" ) then is_file = true end 
    if ( k == "is_nascent" ) then assert(v == true) end 
    -- print(k, v) 
  end
  assert(is_file)
  y:persist()
  assert(y:check())
  print("Successfully completed test t7")
end
--================================
---- test put_chunk
tests.t8 = function()
  local y = Vector.new('I4', qconsts.Q_DATA_DIR)
  assert(y:persist()) -- can persist when nascent
  local buf = cmem.new(chunk_size * 4, "I4")
  local start = 1
  local incr  = 1
  buf:seq(start, incr, chunk_size, "I4")
  y:put_chunk(buf, chunk_size)
  start = 10; incr = 10
  buf:seq(start, incr, chunk_size, "I4")
  y:put_chunk(buf, chunk_size/2)
  y:eov()
  y:persist()
  M = loadstring(y:meta())(); 
  local file_name = M.file_name
  assert(file_name)
  assert(plpath.isfile(file_name))
  print(" od -i " .. file_name .. " # to verify all is good")

--================================
  local y = Vector.new('I4', qconsts.Q_DATA_DIR, file_name)
  print("checking meta data of new vector from old file name ")
  M = loadstring(y:meta())(); 
  for k, v in pairs(M) do 
    if ( k == "field_type" )   then assert(v ==   "I4") end
    if ( k == "chunk_num" )    then assert(v ==  0) end
    if ( k == "num_in_chunk" ) then assert(v ==   0) end
    if ( k == "open_mode" )    then assert(v ==  "NOT_OPEN") end
    if ( k == "is_persist" )   then assert(v ==   false) end
    if ( k == "num_elements" ) then assert(v ==   (chunk_size + chunk_size/2)) end
    if ( k == "is_nascent" )   then assert(v ==   false) end
    if ( k == "is_memo" )      then assert(v == true) end
  end
  assert(y:check())
  print("==================================")
  assert(y:start_write())

  local S = {}
  for j = 1, M.num_elements do
    -- S[j] = Scalar.new(j*10, "I4")
    local s = Scalar.new(j*10, "I4")
    local status = y:set(s, j-1)
    assert(status)
    status = y:set(j*10, j-1)
    assert(status)
    assert(y:check())
    -- you cannot get while you are setting
    if ( j < 10 ) then  -- test for only a few cases
      status = y:get(j-1, 1)
      assert(not status)
    end
  end
  -- should not be able to set after end of vector
  local j = 100000
  local s = Scalar.new(j*10, "I4")
  local status = y:set(s, M.num_elements)
  assert(not status)
  assert(y:end_write())
  -- Can re-open file for writing after closing
  for  i = 1, 5 do
    assert(y:start_write())
    assert(y:end_write())
  end
  --===========================

  y:persist()
  assert(y:check())
  M = loadstring(y:meta())()
  print("Persisting ", M.file_name)
  assert(plpath.isfile(M.file_name))
  print("Successfully completed test t8")
end

--======= do put of a range of lengths and make sure that it works
tests.t9 = function()
  local y = Vector.new('I4', qconsts.Q_DATA_DIR)
  local buf = cmem.new(chunk_size * 4, "I4")
  local start = 1
  local incr  = 1
  buf:seq(start, incr, chunk_size, "I4")
  local cum_size = 0
  for i = 1, 10001 do 
    local status = y:put_chunk(buf, i) -- use chunk size of i
    cum_size = cum_size + i
  end
  y:persist()
  y:eov()
  M = loadstring(y:meta())()
  print("M.file_name = ", M.file_name)
  assert(M.num_elements == cum_size)
  -- MANUAL: If you do od -i of filename, it will be 1,1,2,1,2,3,1,2,3,4...
  print("Successfully completed test t9")
end

return tests
