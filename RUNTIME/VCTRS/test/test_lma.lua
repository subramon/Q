local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local lgutils = require 'liblgutils'

local qtype = "I4"
local max_num_in_chunk = 64
local len = 3 * max_num_in_chunk + 7
local tests = {}
-- test conversion from chunks to lma and back 
tests.t0 = function()
  local x = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "test0_x", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  x:eval()
  assert(x:check())
  assert(x:is_eov())
  for i = 1, 1000 do  
    local old_uqid = x:uqid()
    local y = x:chunks_to_lma():set_name("y_" .. tostring(i))
    assert(type(y) == "lVector")
    assert(y:check())
    assert(y:uqid() ~= old_uqid)
    assert(y:is_lma() == true)

    local old_uqid = y:uqid()
    local xprime = y:lma_to_chunks():set_name("xprime" .. tostring(i))
    assert(type(xprime) == "lVector")
    assert(xprime:check())
    assert(xprime:is_eov() == x:is_eov())
    assert(xprime:num_elements() == x:num_elements())
    assert(xprime:tbsp() == 0)
    assert(xprime:uqid() ~= old_uqid)
    assert(xprime:is_lma() == false)
    assert(xprime:width() == x:width())
    assert(xprime:qtype() == x:qtype())
    local xprime_uqid = xprime:uqid()
    xprime:set_name("xprime")
    local old_uqid = xprime:uqid()
    local xpp = xprime:chunks_to_lma():set_name("xpp" .. tostring(i))
    assert(type(xpp) == "lVector")
    assert(xpp:check())
    assert(xpp:uqid() ~= old_uqid)
  end
  --[[
  local y = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "test0_y", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  y:eval()
  local z = Q.vveq(x, y)
  local r = Q.sum(z)
  local n1, n2 = r:eval()
  assert(n1:to_num() == n2:to_num())
  --]]

  x = nil; collectgarbage()
  assert(cVector.check_all())
  print("Test t0 succeeded")
end
tests.t1 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "test1_x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  print(">>> START DELIBERATE ERROR")
  -- chunks_to_lma can be called only if is_eov == true
  local status = pcall(lVector.chunks_to_lma, x1)
  print("status = ", status)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")
  x1:eval()
  assert(x1:check())
  for i = 1, 1000 do 
    assert(x1:chunks_to_lma())
  end
  x1 = nil; collectgarbage()
  assert(cVector.check_all())
  print("Test t1 succeeded")
end
-- test read access
tests.t2 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "test2_x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  assert(x1:eval())
  assert(x1:is_eov())
  print(">>> START DELIBERATE ERROR")
  local status = pcall(lVector.get_lma_read, x1)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")
  assert(x1:eval())
  assert(x1:is_eov())
  local y1 = x1:chunks_to_lma()

  for i = 1, 1000 do 
    local c = y1:get_lma_read()
    assert(type(c) == "CMEM")
    assert(c:size() == y1:num_elements() * cutils.get_width_qtype(qtype))
    assert(y1:unget_lma_read())
  end
  local C = {}
  for i = 1, 1000 do 
    C[i] = assert(y1:get_lma_read())
    assert(y1:num_readers() == i)
  end
  for i = 1, 1000 do 
    assert(y1:unget_lma_read())
    assert(y1:num_readers() == 1000-i)
  end
  print(">>> START DELIBERATE ERROR")
  local status = pcall(lVector.unget_lma_read, y1)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")

  x1 = nil; y1 = nil; collectgarbage()
  assert(cVector.check_all())
  print("Test t2 succeeded")
end
-- test write access
tests.t3 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype,
    name = "test3_x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  assert(x1:eval())
  assert(x1:is_eov())
  print(">>> START DELIBERATE ERROR")
  local status = pcall(lVector.get_lma_write, x1)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")
  assert(x1:eval())
  assert(x1:is_eov())
  local y1 = x1:chunks_to_lma()
  for i = 1, 1000 do 
    local c = y1:get_lma_write()
    assert(type(c) == "CMEM")
    assert(y1:unget_lma_write())
  end
  -- check for write after read: should fail 
  local c = y1:get_lma_read()
  print(">>> START DELIBERATE ERROR")
  local status = pcall(lVector.get_lma_write, y1)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")
  -- check for write after unread: should succeed
  assert(y1:unget_lma_read())
  local c = y1:get_lma_write()
  assert(type(c) == "CMEM")
  y1:unget_lma_write()
  y1 = nil; y1 = nil; collectgarbage()
  assert(cVector.check_all())
  print("Test t3 succeeded")
end
-- test steal
tests.t4 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype,
    name = "test4_x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  assert(x1:eval())
  assert(x1:is_eov())
  assert(x1:is_lma() == false)
  local y1 = x1:chunks_to_lma()
  local file_name, file_sz = y1:make_lma()
  assert(y1:is_lma() == true)
  assert(type(file_name) == "string")
  assert(plpath.isfile(file_name))
  local chk_file_sz = plpath.getsize(file_name)
  assert(file_sz == chk_file_sz)
  local vargs = {}
  vargs.file_name = file_name
  vargs.name = "clone of y1"
  vargs.qtype = qtype
  vargs.max_num_in_chunk = 64 
  vargs.num_elements = len
  local y = lVector(vargs)
  assert(type(y) == "lVector")
  assert(y:name() == "clone of y1")
  assert(y:qtype() == qtype)
  assert(y:num_elements() == len)
  assert(y:is_eov() == true)
  assert(y:is_lma() == true)
  for i = 1, len do
    local c1 = y1:get1(i-1)
    local c2 = y:get1(i-1)
    assert(c1 == c2)
  end
  -- y.pr()

  local y1_cmem = y1:get_lma_read()
  assert(type(y1_cmem) == "CMEM")
  assert(y1_cmem:size() == file_sz)
  local cast_y1_as = cutils.str_qtype_to_str_ctype(qtype) .. " *"
  local y1_ptr = get_ptr(y1_cmem, cast_y1_as)
  for i = 1, len do 
    assert(y1_ptr[i-1] == i)
  end
  assert(y1:unget_lma_read())
  x1 = nil; y1 = nil; y = nil; collectgarbage()
  assert(cVector.check_all())
  print("Test t4 succeeded")
end
-- test print
tests.t5 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype,
    name = "test5_x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  assert(x1:eval())
  assert(x1:is_eov())
  local y1 = x1:chunks_to_lma()
  -- x1:pr()
  x1 = nil; y1 = nil; collectgarbage()
  assert(cVector.check_all())
  print("Test t5 succeeded")
end
-- test modify 
tests.t6 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype,
    name = "x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  assert(x1:eval())
  local y1 = x1:chunks_to_lma()
  local c = y1:get_lma_write()
  assert(type(c) == "CMEM")
  assert(c:is_foreign())
  local data = get_ptr(c, qtype)
  for i = 1, y1:num_elements() do 
    data[i-1] = i * 10
  end
  y1:unget_lma_write()
  for i = 1, y1:num_elements() do 
    local s = y1:get1(i-1)
    assert(s == Scalar.new(i*10, qtype))
  end 
  y1 = nil; y1 = nil; collectgarbage()
  assert(cVector.check_all())
  print("Test t6 succeeded")
end
-- test num_readers for chunks 
tests.t7 = function()
  local max_num_in_chunk = 64 
  local len = 2 * max_num_in_chunk + 17 
  local num_chunks = math.ceil(len/max_num_in_chunk)
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  x1:eval()

  local C = {}
  local niters = 4000
  for i = 1, niters do 
    local n, cmem  = x1:get_chunk(0)
    assert(n == max_num_in_chunk)
    assert(type(cmem) == "CMEM")
    assert(x1:num_readers(0) == i)
    C[i] = cmem 
  end
  for i = 1, niters do 
    x1:unget_chunk(0)
    assert(x1:num_readers(0) == niters-i)
    C[i] = nil
  end
  x1 = nil; collectgarbage()
  assert(cVector.check_all())
  print("Test t7 succeeded")
end
-- return tests
tests.t0()
tests.t1()
tests.t2()
tests.t3()
tests.t4()
tests.t5()
tests.t6()
tests.t7()
collectgarbage()
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
