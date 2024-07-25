local Q = require 'Q'
local cVector = require 'libvctr'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local qcfg = require 'Q/UTILS/lua/qcfg'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local lgutils = require 'liblgutils'

local max_num_in_chunk = 64 
local qtype = "I4"
local bufsz = max_num_in_chunk * cutils.get_width_qtype(qtype)
local tests = {}
tests.t1 = function()
  local pre = lgutils.mem_used()
  assert(cVector.check_all())

  local x = lVector({qtype = qtype, max_num_in_chunk = max_num_in_chunk})
  assert(x:max_num_in_chunk() == max_num_in_chunk)
  local nfree = 1
  x:set_early_freeable(nfree)
  local b, chk_nfree = x:get_early_freeable()
  assert(b == true)
  assert(chk_nfree == nfree)

  local num_chunks = 10
  for chnk_idx = 0, num_chunks-1 do
    -- print("START Chunk Index " ..  chnk_idx)
    -- Create a chunk worth of data in "buf"
    local buf = cmem.new({size = bufsz, qtype = qtype})
    buf:stealable(true)
    local xptr = get_ptr(buf, qtype)
    for i = 1, max_num_in_chunk do 
      xptr[i-1] = i
    end
    --================
    x:put_chunk(buf, max_num_in_chunk)
    assert(x:max_chnk_idx() == chnk_idx)
    if ( chnk_idx > 0 ) then 
      -- first free will be ignore
      x:early_free(chnk_idx-1)
      local tmp1, tmp2 = x:get_chunk(chnk_idx-1)
      assert(tmp1 == max_num_in_chunk)
      assert(type(tmp2) == "CMEM")
      x:unget_chunk(chnk_idx-1)
      -- second free will be fatal
      x:early_free(chnk_idx-1)
      local tmp1, tmp2 = x:get_chunk(chnk_idx-1)
      assert(tmp1 == 0)
      assert(tmp2 == nil)
    end
    -- print("STOP  Chunk Index " ..  chnk_idx)
    local diff = x:max_chnk_idx() - x:min_chnk_idx()
    assert(diff <= nfree)
  end
  x:eov()
  assert(x:num_elements() == num_chunks  * max_num_in_chunk)
  local b, n = x:get_early_freeable()
  assert(b == true)
  assert(n == 1)

  x:nop()
  x:delete()


  local post = lgutils.mem_used()
  assert(pre == post)
  print("Test t1 succeeded")
end
-- test t2 is when num_free_ignore == 0 (set by default)
-- this changes what gets deleted 
tests.t2 = function()
  local pre = lgutils.mem_used()
  assert(cVector.check_all())

  local bufsz = max_num_in_chunk * cutils.get_width_qtype(qtype)
  local x = lVector({qtype = qtype, max_num_in_chunk = max_num_in_chunk})
  assert(x:max_num_in_chunk() == max_num_in_chunk)
  x:set_early_freeable() -- no arg => default value of 0 used 
  local b, nfree = x:get_early_freeable()
  assert(b == true)
  assert(nfree == 0)

  local num_chunks = 10
  for chnk_idx = 0, num_chunks-1 do
    -- print("START Chunk Index " ..  chnk_idx)
    -- Create a chunk worth of data 
    local buf = cmem.new({size = bufsz, qtype = qtype})
    buf:stealable(true)
    local xptr = get_ptr(buf, qtype)
    for i = 1, max_num_in_chunk do 
      xptr[i-1] = i
    end
    --========================
    x:put_chunk(buf, max_num_in_chunk)
    if ( chnk_idx > 0 ) then 
      x:early_free(chnk_idx-1)
      local tmp1, tmp2 = x:get_chunk(chnk_idx-1)
      assert(tmp1 == 0)
      assert(tmp2 == nil)
    end
    -- print("STOP  Chunk Index " ..  chnk_idx)
  end
  assert(x:min_chnk_idx() == num_chunks-1)
  assert(x:max_chnk_idx() == num_chunks-1)
  x:eov()
  x:delete()

  local post = lgutils.mem_used()
  assert(pre == post)
  print("Test t2 succeeded")
end
-- test t3 is when set_early_freeable is so high that early_free()
-- has no impact
tests.t3 = function()
  local pre = lgutils.mem_used()
  assert(cVector.check_all())

  local bufsz = max_num_in_chunk * cutils.get_width_qtype(qtype)
  local x = lVector({qtype = qtype, max_num_in_chunk = max_num_in_chunk})
  assert(x:max_num_in_chunk() == max_num_in_chunk)
  local nfree = 100
  x:set_early_freeable(nfree) -- some high value 
  local b, chk_nfree = x:get_early_freeable()
  assert(b == true)
  assert(chk_nfree == nfree)
  -- nfree >> num_chunks for this test to work 

  local num_chunks = 10
  for chnk_idx = 0, num_chunks-1 do
    -- print("START Chunk Index " ..  chnk_idx)
    -- Create a chunk worth of data 
    local buf = cmem.new({size = bufsz, qtype = qtype})
    buf:stealable(true)
    local xptr = get_ptr(buf, qtype)
    for i = 1, max_num_in_chunk do 
      xptr[i-1] = i
    end
    --========================
    x:put_chunk(buf, max_num_in_chunk)
    if ( chnk_idx > 0 ) then 
      -- none of these frees should cause a chunk to be deleted
      x:early_free(chnk_idx-1)
      local tmp1, tmp2 = x:get_chunk(chnk_idx-1)
      assert(tmp1 == max_num_in_chunk)
      assert(type(tmp2) == "CMEM")
      x:unget_chunk(chnk_idx-1)
      assert(x:min_chnk_idx() == 0)
    end
    -- print("STOP  Chunk Index " ..  chnk_idx)
  end
  assert(x:min_chnk_idx() == 0)
  assert(x:max_chnk_idx() == num_chunks-1)
  x:eov()
  x:delete()

  local post = lgutils.mem_used()
  assert(pre == post)
  print("Test t3 succeeded")
end
-- test t4 tests free after vector fully created
-- should have no impact 
tests.t4 = function()
  local pre = lgutils.mem_used()
  assert(cVector.check_all())
  local num_lives_free = 5 
  local bufsz = max_num_in_chunk * cutils.get_width_qtype(qtype)

  local x = lVector({qtype = qtype, max_num_in_chunk = max_num_in_chunk})
  assert(x:max_num_in_chunk() == max_num_in_chunk)
  x:set_early_freeable(num_lives_free)
  local b, n = x:get_early_freeable()
  assert(b == true)
  assert(n == num_lives_free)

  -- START create the vector 
  local num_chunks = 10
  for chnk_idx = 0, num_chunks-1 do
    -- create a chunk worth of data 
    local buf = cmem.new({size = bufsz, qtype = qtype})
    buf:stealable(true)
    local xptr = get_ptr(buf, qtype)
    for i = 1, max_num_in_chunk do 
      xptr[i-1] = i
    end
    x:put_chunk(buf, max_num_in_chunk)
  end
  x:eov()
  assert(x:num_elements() == num_chunks  * max_num_in_chunk)
  assert(x:min_chnk_idx() == 0)
  assert(x:max_chnk_idx() == num_chunks-1)
  -- STOP  create the vector 
  for i = 1, num_lives_free do 
    x:early_free(x:max_chnk_idx())
  end
  assert(x:min_chnk_idx() == 0)

  x:delete()

  local post = lgutils.mem_used()
  assert(pre == post)
  print("Test t4 succeeded")
end
tests.t1()
tests.t2()
tests.t3()
tests.t4()
-- return tests
