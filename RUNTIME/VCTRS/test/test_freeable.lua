local Q = require 'Q'
local cVector = require 'libvctr'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local qcfg = require 'Q/UTILS/lua/qcfg'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local lgutils = require 'liblgutils'

local max_num_in_chunk = 64 
local qtype = "I4"
local tests = {}
tests.t1 = function()
  local pre = lgutils.mem_used()
  assert(cVector.check_all())

  local x = lVector({qtype = qtype, max_num_in_chunk = max_num_in_chunk})
  assert(x:max_num_in_chunk() == max_num_in_chunk)
  x:early_freeable(1)
  local b, n, m = x:is_early_free()
  assert(b == true)
  assert(n == 1)

  local num_chunks = 10
  for chnk_idx = 0, num_chunks-1 do
    -- print("START Chunk Index " ..  chnk_idx)
    local bufsz = max_num_in_chunk * cutils.get_width_qtype(qtype)
    local buf = cmem.new({size = bufsz, qtype = qtype})
    buf:stealable(true)
    local xptr = get_ptr(buf, qtype)
    for i = 1, max_num_in_chunk do 
      xptr[i-1] = i
    end
    x:put_chunk(buf, max_num_in_chunk)
    x:early_free()
    if ( chnk_idx > 0 ) then 
      local tmp1, tmp2 = x:get_chunk(chnk_idx-1)
      assert(tmp1 == 0)
      assert(tmp2 == nil)
    end
    -- print("STOP  Chunk Index " ..  chnk_idx)
  end
  x:eov()
  assert(x:num_elements() == num_chunks  * max_num_in_chunk)
  local b, n, m = x:is_early_free()
  assert(b == true)
  assert(n == 1)
  assert(m == num_chunks-1)

  x:delete()


  local post = lgutils.mem_used()
  assert(pre == post)
  print("Test t1 succeeded")
end
-- test t2 differes from t1 in that num_lives_free == 2 
-- this changes what gets deleted 
tests.t2 = function()
  local pre = lgutils.mem_used()
  assert(cVector.check_all())

  local x = lVector({qtype = qtype, max_num_in_chunk = max_num_in_chunk})
  assert(x:max_num_in_chunk() == max_num_in_chunk)
  x:early_freeable(2)
  local b, n, m = x:is_early_free()
  assert(b == true)
  assert(n == 2)
  assert(m == 0)

  local num_chunks = 10
  for chnk_idx = 0, num_chunks-1 do
    -- print("START Chunk Index " ..  chnk_idx)
    local bufsz = max_num_in_chunk * cutils.get_width_qtype(qtype)
    local buf = cmem.new({size = bufsz, qtype = qtype})
    buf:stealable(true)
    local xptr = get_ptr(buf, qtype)
    for i = 1, max_num_in_chunk do 
      xptr[i-1] = i
    end
    x:put_chunk(buf, max_num_in_chunk)
    x:early_free()
    if ( chnk_idx > 0 ) then 
      local tmp1, tmp2 = x:get_chunk(chnk_idx-1)
      assert(tmp1 ~= 0)
      assert(type(tmp2) == "CMEM")
      x:unget_chunk(chnk_idx-1)
    end
    -- print("STOP  Chunk Index " ..  chnk_idx)
  end
  x:eov()
  assert(x:num_elements() == num_chunks  * max_num_in_chunk)
  local b, n, m = x:is_early_free()
  assert(b == true)
  assert(n == 2)
  assert(m == num_chunks-2) -- IMPORTANT

  x:delete()


  local post = lgutils.mem_used()
  assert(pre == post)
  print("Test t2 succeeded")
end
tests.t1()
tests.t2()
-- return tests
