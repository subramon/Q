require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local pldir   = require 'pl.dir'

local tests = {}
lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
--=================================
local chunk_size = 65536
local params = { chunk_size = chunk_size, sz_chunk_dir = 4096, 
      data_dir = qconsts.Q_DATA_DIR }
cVector.init_globals(params)
assert(cVector.chunk_size() == chunk_size)
--=================================
-- testing put1 and get1 
tests.t1 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v = lVector.new( { qtype = qtype, width = width} )
  
  local n = 10
  for i = 1, n do 
    local s = Scalar.new(i, qtype)
    v:put1(s)
  end
  -- cannot clone until eov tru 
  local status, msg = pcall(v.clone, v)
  assert(not status)
  ----
  v:eov()
  local w = v:clone()
  assert(type(w) == "lVector")
  for i = 1, n do 
    assert(w:get1(i-1) == v:get1(i-1))
  end
  w:eov()
  print("Test t1 completed")
end
return tests
-- tests.t1()
