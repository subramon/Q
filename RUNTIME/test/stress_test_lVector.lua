local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local Vector  = require 'libvec'  
local Scalar  = require 'libsclr'  
local cmem    = require 'libcmem'  
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qc = require 'Q/UTILS/lua/q_core'
local utils = require 'Q/UTILS/lua/utils'
require 'Q/UTILS/lua/strict'

local tests = {} 
local num_chunks = 8
--local num_iters = 65536
-- 
tests.t1 = function()
  local start_time = qc.RDTSC()
  local num_iters = 256
  for i = 1, num_iters do
    local qtype = "I4"
    local x = lVector( { qtype = qtype, gen = true, name = "x"})
    local num_elements = (num_chunks * qconsts.chunk_size) + 3
    local width = qconsts.qtypes[qtype].width
    local num_bytes = num_elements * width
    local base_data = cmem.new(num_bytes, "I4", "base")
    local chunk_num = 0
    local chunk_idx = 1
    for i = 1, num_elements do
      local s1 = Scalar.new(i*11, "I4")
      local s2 
      if ( ( i % 2 ) == 0 ) then
        s2 = Scalar.new(true, "B1")
      else
        s2 = Scalar.new(false, "B1")
      end
      x:put1(s1, s2)

      local a, b, c, d = x:chunk(chunk_num)
      if ( ( i % qconsts.chunk_size ) == 0 ) then 
        chunk_num = chunk_num + 1
      end
      if ( ( i % qconsts.chunk_size ) == 1 ) then 
        chunk_idx = 1
      end
      assert(a == chunk_idx)
      --[[
      if ( a < qconsts.chunk_size ) then 
        assert(a == i)
      else
        assert(a == qconsts.chunk_size)
      end
      --]]
      assert(type(b) == "CMEM")
      assert(type(c) == "CMEM") -- because there is a null vector
      assert(d == nil)
      local s1, s2 = x:get_one(i-1)
      assert(type(s1) == "Scalar")
      assert(s1:fldtype() == "I4")
      assert(type(s2) == "Scalar")
      assert(s2:fldtype() == "B1")
      chunk_idx = chunk_idx + 1
    end
    x:eov()
    local T = x:meta()
    assert(plpath.isfile(T.base.file_name))
  end
  local stop_time = qc.RDTSC()
  print("stress_test_lVector t1 time(seconds): ", utils["RDTSC"](stop_time-start_time))
  print("Successfully completed RUNTIME/test/stress_test_lVector.lua --t1")
end

tests.t2 = function()
  local start_time = qc.RDTSC()
  local num_iters = 512
  for i = 1, num_iters do
    local qtype = "I8"
    local x = lVector( { qtype = qtype, gen = true, name = "x"})
    local num_elements = num_chunks * qconsts.chunk_size
    local width = qconsts.qtypes[qtype].width
    local num_bytes = num_elements * width
    local base_data = cmem.new(num_bytes, qtype, "base")
    for i = 1, num_elements do
      local s1 = Scalar.new(i*11, qtype)
      local s2 
      if ( ( i % 2 ) == 0 ) then
        s2 = Scalar.new(true, "B1")
      else
        s2 = Scalar.new(false, "B1")
      end
      x:put1(s1, s2)
    end
    for j = 1, num_iters do
      for cidx = 1, num_chunks do
        local a, b, c, d = x:chunk(cidx-1)
        assert(type(a) == "number")
        assert(type(b) == "CMEM")
        assert(type(c) == "CMEM") 
      end
    end
  end
  local stop_time = qc.RDTSC()
  print("stress_test_lVector t2 time (seconds): ", utils["RDTSC"](stop_time-start_time))
  print("Successfully completed RUNTIME/test/stress_test_lVector.lua --t2")
end

return tests
