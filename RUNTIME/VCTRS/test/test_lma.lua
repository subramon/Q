require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'

local max_num_in_chunk = 16 
local len = 3 * max_num_in_chunk + 7
local tests = {}
tests.t1 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = "I4",
    name = "x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  print(">>> START DELIBERATE ERROR")
  local status = pcall(lVector.chunks_to_lma, x1)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")
  x1:eval()
  for i = 1, 1000 do 
    assert(x1:chunks_to_lma())
    assert(x1:del_lma())
  end
  print("Test t1 succeeded")
end
-- test read access
tests.t2 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = "I4",
    name = "x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  assert(x1:eval())
  assert(x1:is_eov())
  print(">>> START DELIBERATE ERROR")
  local status = pcall(lVector.get_lma_read, x1)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")
  assert(x1:eval())
  assert(x1:is_eov())
  assert(x1:chunks_to_lma())
  for i = 1, 1000 do 
    local c = x1:get_lma_read()
    assert(type(c) == "CMEM")
    -- TODO check size of c 
    assert(x1:unget_lma_read())
  end
  local C = {}
  for i = 1, 1000 do 
    C[i] = assert(x1:get_lma_read())
  end
  for i = 1, 1000 do 
    assert(x1:unget_lma_read())
  end
  print(">>> START DELIBERATE ERROR")
  local status = pcall(lVector.unget_lma_read, x1)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")
  print("Test t2 succeeded")
end
-- test write access
tests.t3 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = "I4",
    name = "x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  assert(x1:eval())
  assert(x1:is_eov())
  print(">>> START DELIBERATE ERROR")
  local status = pcall(lVector.get_lma_write, x1)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")
  assert(x1:eval())
  assert(x1:is_eov())
  assert(x1:chunks_to_lma())
  for i = 1, 1000 do 
    local c = x1:get_lma_write()
    assert(type(c) == "CMEM")
    -- TODO check size of c 
    assert(x1:unget_lma_write())
  end
  -- check for write after read: should fail 
  local c = x1:get_lma_read()
  print(">>> START DELIBERATE ERROR")
  local status = pcall(lVector.get_lma_write, x1)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")
  -- check for write after unread: should succeed
  assert(x1:unget_lma_read())
  local c = x1:get_lma_write()
  assert(type(c) == "CMEM")
  x1:unget_lma_write()
  print("Test t3 succeeded")
end
-- return tests
tests.t1()
tests.t2()
tests.t3()
-- os.exit()
