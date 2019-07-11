local cmem = require 'libcmem' ; 
local ffi = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local release_ptr = require 'Q/UTILS/lua/release_ptr'
local tests = {}
local qconsts = require 'Q/UTILS/lua/q_consts'

ffi.cdef([[
char *strncpy(char *dest, const char *src, size_t n);
]]
)

tests.t0 = function()
  -- basic test 
  local buf = cmem.new(128, "I4")
  assert(type(buf) == "CMEM")
  buf:zero()
  y = buf:to_str("I4")
  assert(y == "0")
  buf:prbuf(4)
  print("test 0 passed")
end

tests.t1 = function()
  -- basic test 
  local buf = cmem.new(128, "I4")
  assert(type(buf) == "CMEM")
  buf:set(65535, "I4")
  y = buf:to_str("I4")
  print(y)
  assert(y == "65535")
  print("test 1 passed")
end

tests.t2 = function()
  local buf = cmem.new(128, "I4")
  local num_trials = 10 -- 1024*1048576
  local sz = 65537
  for j = 1, num_trials do 
    local buf = cmem.new(sz, "I4", "inbuf")
    buf:set(j, "I4") -- for debugging
    -- print(buf, "I4")
    x = buf:to_str("I4")
    assert(j == tonumber(x))
    -- print(j, x)
    buf = nil
  end
  local num_elements = 1024
  local buf = cmem.new(num_elements * 4, "I4")
  local start = 123
  local incr  = 1
  buf:seq(start, incr, num_elements, "I4")
  x = buf:to_str("I4")
  assert(start == tonumber(x))
  -- check using FFI
  iptr = assert(get_ptr(buf, "I4"))
  for i = 1, num_elements do
    assert(iptr[i-1] == start + (i-1) * incr)
  end
  --=======================
  release_ptr(buf)
  print("test 2 passed")
end

tests.t3 = function()
  -- setting data using ffi and verifying using to_str()
  local buf = cmem.new(ffi.sizeof("int32_t"), "I4")
  cbuf = ffi.cast("CMEM_REC_TYPE *", buf)
  ffi.C.strncpy(cbuf[0].field_type, "I4", 2)
  ffi.C.strncpy(cbuf[0].cell_name, "some bogus name", 15)
  iptr = assert(get_ptr(buf, "I4"))
  iptr[0] = 123456789;
  assert(type(buf) == "CMEM")
  y = buf:to_str("I4")
  assert(y == "123456789")
  assert(buf:fldtype() == "I4")
  assert(buf:name() == "some bogus name")
  print("test 3 passed")
end

tests.t4 = function()
  -- using set 
  local buf = cmem.new(ffi.sizeof("int"), "I4")
  buf:set(123456789)
  y = buf:to_str("I4")
  assert(y == "123456789")
  assert(buf:fldtype() == "I4")
  print("test t4 passed")
end


tests.t5 = function()

  -- test foreign functionality
  local size = 1024
  local qtype = "I4"
  local name = "some bigus name"
  local c1 = cmem.new(size, qtype, name)
  c1:set(123456789)

  local niters = 100000
  for i = 1, niters do 
    local iptr = c1:data()
    assert(type(iptr) == "userdata")
    local c2 = cmem.dupe(iptr, size, qtype, name)
    assert(c2:is_foreign() == true)
    c2:set(987654321)
  end
  assert(c1:to_str("I4") == "987654321")
  print("test t5 passed")
end

tests.t6 = function()
  -- test meta fucntionality
  local size = 1024
  local qtype = "I8"
  local name = "some bogus name"
  local c1 = assert(cmem.new(size, qtype, name))
  assert(c1:size() == size)
  assert(c1:fldtype() == qtype)
  assert(c1:name() == name)
  assert(c1:is_foreign() == false)
  print("test t6 passed")
end

tests.t7 = function()
  -- test SC with good values 
  local gval = {}
  gval[1] = "1234567";
  gval[2] = "123.567";
  gval[3] = ""
  gval[4] = " abcd "
  local size = 8
  local qtype = "SC"
  local name = "some bogus name"
  for k, v in ipairs(gval) do 
  local c1 = assert(cmem.new(size, qtype, name))
    c1:set(v)
    y = c1:to_str("SC")
    print(y)
    assert(y == v)
  end
  print("test t7 passed")
end
  
tests.t8 = function()
  -- test SC with bad values 
  local bval = {}
  bval[1] = "1234567890123456";
  local size = 16
  local qtype = "SC"
  local name = "some bogus name"
  for k, v in ipairs(bval) do 
    local c1 = assert(cmem.new(size, qtype, name))
    print("START: Deliberate error")
    local x = c1:set(v)
    print("STOP: Deliberate error")
    assert(x == nil)
  end
  print("test t8 passed")
end
  
tests.t9 = function()
  -- this is a regression test to guard against malloc'ing less
  -- than what user asked for 
  local n = 1048576
  local size = 4*n
  local c1 = assert(cmem.new(size, "I4"))
  local iptr = get_ptr(c1, "I4")
  for i = 1, n do
    iptr[i-1] = i
  end
  print("test t9 passed")
end

tests.t10 = function()
  -- tests set min and max 
  local n = 16
  local qtypes = { }
  qtypes.I1 = 1
  qtypes.I2 = 2
  qtypes.I4 = 4
  qtypes.I8 = 8
  qtypes.F4 = 4
  qtypes.F8 = 8
  for qtype, width in pairs(qtypes) do 
    print(qtype, width)
    local size = width * n
    local c1 = assert(cmem.new(size, qtype))
    c1:set_min()
    -- c1:prbuf(n)
    c1:set_max()
    -- c1:prbuf(n)
  end
  -- TODO P3 Visual inspection shows this test passes. Automate it.
  print("test t10 passed")
end

tests.t11 = function()
  local num_elements = 10
  local qtype = "I4"
  local buf = cmem.new((num_elements * 4), qtype)
  local iptr = get_ptr(buf, qtype)
  
  buf:set_min()
  -- verify min values
  for i = 1, num_elements do
    assert(iptr[i-1] == qconsts.qtypes[qtype].min)
  end

  buf:set_max()
  -- verify min values
  for i = 1, num_elements do
    assert(iptr[i-1] == qconsts.qtypes[qtype].max)
  end

  local val = -1
  buf:set_default(val)
  -- verify min values
  for i = 1, num_elements do
    assert(iptr[i-1] == val)
  end

  --=======================
  print("test t11 passed")
end
tests.t12 = function()
  -- test set cell name 
  local size = 1024
  local qtype = "I4"
  local name = "some bigus name"
  local c1 = cmem.new(size, qtype, name)
  assert(c1:name() == name)
  print("test t12 passed")
end


  
return tests
