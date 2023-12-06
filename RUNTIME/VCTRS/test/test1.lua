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
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local x, y = lVector({ qtype = "F4", width = 4})
  assert(type(x) == "lVector")
  assert(type(y) == "nil") -- only one thing returned
  assert(cVector.check_all())
  x:delete()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  collectgarbage("restart")
  print("Test t1 succeeded")
end
tests.t2 = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local qtype = "I4"
  local max_num_in_chunk = 64
  local x = lVector({ qtype = qtype, max_num_in_chunk = max_num_in_chunk })
  local width = cutils.get_width_qtype(qtype)
  assert(x:width() == width)
  assert(x:max_num_in_chunk() == max_num_in_chunk)
  -- create a buffer for data to put into vector 
  local size = 1 * width
  local buf = cmem.new( {size = size, qtype = qtype, name = "inbuf"})
  -- put some stuff
  local iptr = assert(get_ptr(buf, qtype))
  for i = 1, 2*max_num_in_chunk+1 do 
    iptr[0] = i + 1 
    x:putn(buf, 1)
    assert(x:num_elements() == i)
  end
  local status = x:eov()
  assert(status)
  assert(x:is_eov() == true)
  assert(x:eov())
  assert(cVector.check_all())
  buf:delete()
  x:delete()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  collectgarbage("restart")
  print("Test t2 succeeded")
end
tests.t3 = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
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
    assert(x:is_eov() == false)
    assert(x:num_elements() == i*max_num_in_chunk)
    -- get what you put 
    local n, c = x:get_chunk(i-1)
    assert(type(c) == "CMEM")
    assert(type(n) == "number")
    assert(n == max_num_in_chunk)
    -- check values are what you put in 
    local iptr = assert(get_ptr(c, qtype))
    for  j = 1, max_num_in_chunk do 
      assert(iptr[j-1] == (i+1)*100 + (j+1))
    end
    x:unget_chunk(i-1)
    x:check(false)
  end
  assert(x:is_eov() == false)
  x:put_chunk(buf, max_num_in_chunk-1)
  assert(x:is_eov() == true)
  x:nop()
  assert(x:num_elements() == 
    (num_chunks*max_num_in_chunk) + (max_num_in_chunk-1))
  -- get what you put 
  local n, c = x:get_chunk(num_chunks)
  x:unget_chunk(num_chunks)
  assert(type(c) == "CMEM")
  assert(type(n) == "number")
  assert(n == max_num_in_chunk-1)
  -- cannot put once eov 
  print(">>> START Deliberate error")
  local status = pcall(lVector.put_chunk, x, buf, max_num_in_chunk-1)
  assert(status == false)
  print(">>> STOP  Deliberate error")
  assert(x:check())
  -- test printing
  assert(x:pr("_x", 0, 10))
  x:nop()
  x:delete()
  buf:delete()
  collectgarbage()

  assert(cVector.check_all())
  print("Test t3 succeeded")
end
tests.t4 = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  -- this is a dangerous test - not recommended practive
  -- in the way it rehydrates a Vector
  -- But good as a test
  local qtype = "I4"
  local max_num_in_chunk = 64
  local width = cutils.get_width_qtype(qtype)

  -- NOTE: x is a global below 
  x = lVector({ name = "xvec", qtype = qtype, max_num_in_chunk = max_num_in_chunk })
  assert(cVector.check_all())
  assert(x:name() == "xvec")
  -- print("Created vector " .. x:name() .. " with uqid = " .. x:uqid())
  -- create a buffer for data to put into vector 
  local size = max_num_in_chunk * width
  local buf = cmem.new( {size = size, qtype = qtype, name = "inbuf"})
  -- put some stuff
  local num_chunks = 4
  local counter = 10
  local iptr = assert(get_ptr(buf, qtype))
  for i = 1, num_chunks do 
    for  j = 1, max_num_in_chunk do 
      iptr[j-1] = counter
      counter = counter + 10
    end

    local x1 = buf:to_str("I4")
    local y1 = loadstring(x1)
    local z1 = y1()
    x:put_chunk(buf, max_num_in_chunk)
    local n, buf2 = x:get_chunk(i-1)
    assert(type(buf2) == "CMEM")
    assert(type(n) == "number")
    assert(n == max_num_in_chunk)
    -- don't forget that to_str on CMEM prints only a limited number
    -- of values, for upper bound look up cmem.c 

    local x2 = buf2:to_str("I4")
    local y2 = loadstring(x2)
    local z2 = y2()
    for k, v in pairs(z1) do 
      assert(z1[k] == z2[k])
    end
    x:unget_chunk(i-1)
  end
  assert(x:is_eov() == false)
  x:put_chunk(buf, max_num_in_chunk-1)
  assert(x:is_eov() == true)
  --============================
  assert(x:memo_len() == qcfg.memo_len)
  assert(x:max_num_in_chunk() == max_num_in_chunk)
  x:pr("/tmp/_x")
  --============================
  local uqid = x:uqid()
  assert(type(uqid) == "number")
  assert(uqid > 0)
  local args = { uqid = uqid }
  assert(cVector.check_all())
  x:nop()
  y = lVector(args)
  assert(type(y) == "lVector")
  -- print("Created vector " .. y:name() .. " with uqid = " .. y:uqid())
  y:pr("/tmp/_y")
  y:set_name("yvec")
  -- Check that x and y are in globals
  local xfound = false; local yfound = false
  for k, v in pairs(_G) do 
    if ( k == "x") then xfound = true; assert(type(x) == "lVector")  end 
    if ( k == "y") then yfound = true; assert(type(x) == "lVector") end 
  end

  assert(x:check()) -- checking on this vector
  assert(cVector.check_all())
  x:nop()
  print("before save", lgutils.mem_used())
  Q.save()
  print("aftere save", lgutils.mem_used())
  local ydata = pldata.read("/tmp/_y")
  assert(#ydata == x:num_elements())
  -- Note that we test data for all except last chunk 
  counter = 10
  for i = 1, num_chunks do 
    assert(ydata[i][1] == counter)
    counter = counter + 10 
  end
  x:delete()
  buf:delete()
  assert(cVector.check_all())
  collectgarbage("restart")
  print("Test t4 succeeded")
end
-- return tests
tests.t1()
tests.t2()
tests.t3()
-- TODO tests.t4() --- needs work in save()
