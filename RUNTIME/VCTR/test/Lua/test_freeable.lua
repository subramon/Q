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
-- test t3 generalizes t1 and t2 
tests.t3 = function()
  local pre = lgutils.mem_used()
  assert(cVector.check_all())
  local num_chunks = 10

  for num_lives_free = 1, num_chunks do 
    local x = lVector({qtype = qtype, max_num_in_chunk = max_num_in_chunk})
    assert(x:max_num_in_chunk() == max_num_in_chunk)
    x:early_freeable(num_lives_free)
    local b, n, m = x:is_early_free()
    assert(b == true)
    assert(n == num_lives_free)
    assert(m == 0)
  
    local bufsz = max_num_in_chunk * cutils.get_width_qtype(qtype)
    local buf = cmem.new({size = bufsz, qtype = qtype})
    buf:stealable(false)
    for chnk_idx = 0, num_chunks-1 do
      -- print("START Chunk Index " ..  chnk_idx)
      local xptr = get_ptr(buf, qtype)
      for i = 1, max_num_in_chunk do 
        xptr[i-1] = (chnk_idx*max_num_in_chunk)+i
      end
      x:put_chunk(buf, max_num_in_chunk)
      x:early_free()
      local ub_freed = chnk_idx - num_lives_free
      local lb_freed = 0
      for k = lb_freed, ub_freed do 
        local tmp1, tmp2 = x:get_chunk(k)
        assert(tmp1 == 0)
        assert(tmp2 == nil)
      end
      -- print("STOP  Chunk Index " ..  chnk_idx)
    end
    buf:delete()
    x:eov()
    assert(x:num_elements() == num_chunks  * max_num_in_chunk)
    local b, n, m = x:is_early_free()
    assert(b == true)
    assert(n == num_lives_free)
    assert(m == num_chunks-num_lives_free)
    x:delete()
  
    local post = lgutils.mem_used()
    assert(pre == post)
    print("Test t3 succeeded for free lives = ", num_lives_free)
  end
  print("Test t3 succeeded")
end
-- test t4 tests free after vector fully created
tests.t4 = function()
  local pre = lgutils.mem_used()
  assert(cVector.check_all())
  local num_lives_free = 5 

  local x = lVector({qtype = qtype, max_num_in_chunk = max_num_in_chunk})
  assert(x:max_num_in_chunk() == max_num_in_chunk)
  x:early_freeable(num_lives_free)
  local b, n, m = x:is_early_free()
  assert(b == true)
  assert(n == num_lives_free)
  assert(m == 0)

  -- START create the vector 
  local num_chunks = 10
  for chnk_idx = 0, num_chunks-1 do
    local bufsz = max_num_in_chunk * cutils.get_width_qtype(qtype)
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
  -- STOP  create the vector 
  for i = 1, num_lives_free do 
    x:early_free()
    local b, n, m = x:is_early_free()
    assert(b == true)
    assert(n == num_lives_free)
    if ( i < num_lives_free ) then 
      assert(m == 0)
    else
      assert(m == num_chunks-1)
    end 
  end

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
