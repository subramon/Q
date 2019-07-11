local plpath = require 'pl.path'
local plfile = require 'pl.file'
local Vector = require 'libvec' 
local Scalar = require 'libsclr' 
local cmem = require 'libcmem'  
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'
local gen_bin = require 'Q/RUNTIME/test/generate_bin'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local ffi     = require 'Q/UTILS/lua/q_ffi'
require 'Q/UTILS/lua/strict'

---- test large file created on materialization
local tests = {}
tests.t1 = function()
  local y = Vector.new('I4', qconsts.Q_DATA_DIR)
  local chunk_size = qconsts.chunk_size
  local width = y:field_size()
  local buf = cmem.new(chunk_size * 4, "I4")
  local n = 16384
  local M, file_name, file_size
  for i = 1, n do 
    y:put_chunk(buf, chunk_size)
    M = loadstring(y:meta())(); 
    file_name = M.file_name
    if ( i == 1 ) then 
      assert(not file_name)
    else
      assert(file_name)
      assert(plpath.isfile(file_name))
      file_size = qc.get_file_size(file_name)
      assert(file_size == (width * chunk_size * (i-1)))
    end
  end
  y:persist()
  y:flush_buffer()
  file_size = qc.get_file_size(file_name)
  assert(file_size == (n * chunk_size * width))
  print(" od -i " .. file_name .. " # to verify all is good")
  plfile.delete(file_name)
  assert(not plpath.isfile(file_name))
end
return tests
-- tests.t1()
--================================
