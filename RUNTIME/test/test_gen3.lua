local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local Vector  = require 'libvec'  
local Scalar  = require 'libsclr'  
local cmem    = require 'libcmem'  
local lVector = require 'Q/RUNTIME/lua/lVector'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local ffi = require 'ffi'
local gen_bin = require 'Q/RUNTIME/test/generate_bin'
local expander_gen3 = require 'Q/RUNTIME/test/expander_gen3'

local tests = {} 

--====== Testing nascent vector with generator (gen3)

tests.t1 = function()
  -- generating required .bin file 
  qc.generate_bin(10, "I4","_in1_I4.bin", "linear")
  print("Creating nascent vector with generator gen3")

  local v1 = lVector( { qtype = "I4", file_name = "_in1_I4.bin"})
  local gen3 = expander_gen3(v1, v1)

  local x = lVector( { qtype = "I4", gen = gen3, has_nulls = false})
  local chunk_idx = 0
  repeat
    local len, addr, nn_addr = x:chunk(chunk_idx)
    print("len/chunk_idx = ", len, chunk_idx)
    chunk_idx = chunk_idx + 1
  until (len == 0)
  assert(x:num_elements() == 5600)
  print("Successfully completed test t1")
end

return tests
