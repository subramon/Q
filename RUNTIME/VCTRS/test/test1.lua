local cmem   = require 'libcmem'
local cutils = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local tests = {}
tests.t1 = function()
  local x, y = lVector({ qtype = "F4", width = 4, chunk_size = 0 })
  assert(type(x) == "lVector")
  assert(type(y) == "nil") -- only one thing returned
  x = nil
  collectgarbage()
  print("Test t1 succeeded")
end
tests.t2 = function()
  local qtype = "I4"
  local max_num_in_chnk = 16
  local x = lVector({ qtype = qtype, max_num_in_chunk = max_num_in_chnk })
  local width = cutils.get_width_qtype(qtype)
  assert(x:width() == width)
  -- create a buffer for data to put into vector 
  local size = 1 * width
  local buf = cmem.new( {size = size, qtype = qtype, name = "inbuf"})
  -- put some stuff
  local iptr = assert(get_ptr(buf, qtype))
  for i = 1, 2*max_num_in_chnk+1 do 
    iptr[0] = i + 1 
    x:put1(buf, 1)
    assert(x:num_elements() == i)
  end
  local status = x:eov()
  assert(status == true)
  assert(x:is_eov() == true)
  print(">>> START Deliberate error")
  local status = x:eov()
  assert(not status)
  print("<<< STOP  Deliberate error")

  print("Test t2 succeeded")
end
tests.t3 = function()
  local qtype = "I4"
  local max_num_in_chnk = 16
  -- NOTE: x is a global below 
  x = lVector({ qtype = qtype, max_num_in_chunk = max_num_in_chnk })
  local width = cutils.get_width_qtype(qtype)
  assert(x:width() == width)
  -- create a buffer for data to put into vector 
  local size = max_num_in_chnk * width
  local buf = cmem.new( {size = size, qtype = qtype, name = "inbuf"})
  -- put some stuff
  local num_chunks = 4
  for i = 1, num_chunks do 
    local iptr = assert(get_ptr(buf, qtype))
    for  j = 1, max_num_in_chnk do 
      iptr[j-1] = (i+1)*100 + (j+1)
    end
    print("i = ", i)
    x:put_chunk(buf, max_num_in_chnk)
    assert(x:is_eov() == false)
    print(x:num_elements(), i*max_num_in_chnk)
    assert(x:num_elements() == i*max_num_in_chnk)
    -- get what you put 
    local c, n = x:get_chunk(i-1)
    assert(type(c) == "CMEM")
    assert(type(n) == "number")
    assert(n == max_num_in_chnk)
    -- check values are what you put in 
    local iptr = assert(get_ptr(c, qtype))
    for  j = 1, max_num_in_chnk do 
      assert(iptr[j-1] == (i+1)*100 + (j+1))
    end
  end
  assert(x:is_eov() == false)
  x:put_chunk(buf, max_num_in_chnk-1)
  assert(x:is_eov() == true)
  assert(x:num_elements() == 
    (num_chunks*max_num_in_chnk) + (max_num_in_chnk-1))
  -- get what you put 
  local c, n = x:get_chunk(num_chunks)
  assert(type(c) == "CMEM")
  assert(type(n) == "number")
  assert(n == max_num_in_chnk-1)
  -- cannot put once eov 
  print(">>> START Deliberate error")
  local status = pcall(lVector.put_chunk, x, buf, max_num_in_chnk-1)
  assert(status == false)
  print(">>> STOP  Deliberate error")
  -- test printing
  x:pr(nil, 0, 10)
  -- test globals
  for k, v in pairs(_G) do 
    if ( type(v) == "lVector") then print (k) end
  end

  print("Test t3 succeeded")
end
-- return tests
tests.t1()
tests.t2()
tests.t3()

