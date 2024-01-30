local Q = require 'Q'
local pldata = require 'pl.data'

local cmem     = require 'libcmem'
local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local cVector  = require 'libvctr'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qcfg     = require 'Q/UTILS/lua/qcfg'

local tests = {}
tests.t1 = function()
  collectgarbage("stop")
  local m1 = lgutils.mem_used()
  local qtype = "I4"
  local max_num_in_chunk = 64
  -- NOTE: x is a global below 
  x = lVector({ qtype = qtype, max_num_in_chunk = max_num_in_chunk })
  local width = cutils.get_width_qtype(qtype)
  assert(x:width() == width)
  x:set_name("xvec")
  -- create a buffer for data to put into vector 
  local size = max_num_in_chunk * width
  local buf = cmem.new( {size = size, qtype = qtype, name = "inbuf"})
  -- put some stuff
  local num_chunks = 4
  for i = 1, num_chunks do 
    local iptr = assert(get_ptr(buf, qtype))
    for  j = 1, max_num_in_chunk do 
      iptr[j-1] = (i+1)*100 + (j+1)
    end
    x:put_chunk(buf, max_num_in_chunk)
  end
  -- declare end of data 
  buf:delete()
  x:eov()
  -- verify you have consumed more memory than at start
  local m2 = lgutils.mem_used()
  assert (m2 > m1)
  -- create another reference to the vector
  local y = x 
  -- garbage collection should NOT delete the vector because there is 
  -- another reference to it 
  x = nil
  collectgarbage()
  local m3 = lgutils.mem_used()
  assert (m2 == m3)
  -- if you delete y as well, then garbage collection SHOULD 
  -- delete the vector
  y = nil
  collectgarbage()
  local m4 = lgutils.mem_used()
  print(m1, m2, m3, m4)
  assert (m1 == m4)
  print("Test t1 succeeded")
end
-- return tests
tests.t1()
