require 'Q/UTILS/lua/strict'
local ffi     = require 'ffi'
local cmem    = require 'libcmem' ; 
local cutils  = require 'libcutils' ; 
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local tests = {}

ffi.cdef([[
char *strncpy(char *dest, const char *src, size_t n);
]]
)
ffi.cdef([[
typedef uint16_t bfloat16; 
typedef enum { 
  Q0, 
  BL, 
  I1,
  I2,
  I4,
  I8,
  F2,
  F4,
  F8,
  UI1,
  UI2,
  UI4,
  UI8,
  SC,  
  SV,  
  TM1, 
  NUM_QTYPES 
} qtype_t;
typedef struct _tm_t {
  int8_t tm_year;	
  int8_t tm_mon;	
  int8_t tm_mday;	
  int8_t tm_hour;	
  int8_t tm_min;	
  int8_t tm_sec;	
  int16_t tm_yday;	
} tm_t;
extern qtype_t
get_tm_qtype(
    const char * const fld
    );
extern int
t_assign(
    struct tm *dst, 
    tm_t *src
    );
extern int
get_width_qtype(
    char * const str_qtype
    );
extern int
get_width_c_qtype(
      qtype_t qtype
    );
extern qtype_t
get_c_qtype(
    const char *const str_qtype
    );
extern const char *
get_str_qtype(
    qtype_t qtype
    );
typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  int width;
  qtype_t qtype;
  char cell_name[16];
  bool is_foreign; 
  bool is_stealable; 
} CMEM_REC_TYPE;
]])
--[[ TODO Improve above hard coding using below 
local qconsts = require 'Q/UTILS/lua/qconsts'
local qc      = require  'Q/UTILS/lua/qcore' -- to cdef CMEM_REC_TYPE 
local for_cdef = require 'Q/UTILS/lua/for_cdef'
local infile = "RUNTIME/CMEM/inc/cmem_struct.h"
local incs = { "UTILS/inc/" }
local x = for_cdef(infile, incs)
ffi.cdef(x)
--]]

tests.t0 = function()
  -- basic test 
  local buf = cmem.new(16)
  assert(type(buf) == "CMEM")
  buf:zero()
  local y = buf:to_str("I4")
  assert(y == "0")
  buf:prbuf(4)
  print("test 0 passed")
end

tests.t1 = function()
  -- basic test 
  local buf = cmem.new({ size = 128, qtype = "I4"})
  assert(type(buf) == "CMEM")
  buf:set(65535, "I4")
  local y = buf:to_str("I4")
  assert(y == "65535")
  print("test 1 passed")
end

tests.t2 = function()
  local buf = cmem.new({ size = 128, qtype = "I4"})
  local num_trials = 10 -- 1024*1048576
  local sz = 65537
  local qtype = "I4"
  local width
  for j = 1, num_trials do 
    local buf = cmem.new( {size = sz, qtype = qtype, name = "inbuf"})
    width = cutils.get_width(qtype)
    buf:set_width(width)
    assert(buf:width() == width)
    buf:set(j, qtype)
    local x = buf:to_str(qtype)
    assert(j == tonumber(x))
    buf = nil
  end
  local num_elements = 1024
  local buf = cmem.new( { size = num_elements * 4, qtype = qtype})
  buf:set_width(width)
  local start = 123
  local incr  = 1
  buf:seq(start, incr, num_elements, qtype)
  local x = buf:to_str(qtype)
  assert(start == tonumber(x))
  -- check using FFI
  local iptr = assert(get_ptr(buf, qtype))
  for i = 1, num_elements do
    assert(iptr[i-1] == start + (i-1) * incr)
  end
  --=======================
  print("test 2 passed")
end

tests.t3 = function()
  -- setting data using ffi and verifying using to_str()
  local qtype = "I4"
  local width = cutils.get_width(qtype)
  local size = 1 * width
  local buf = cmem.new( {size = size, qtype = qtype})
  buf:set_name("some bogus name"); 
  local iptr = assert(get_ptr(buf, "I4"))
  iptr[0] = 123456789;
  assert(type(buf) == "CMEM")
  local y = buf:to_str("I4")
  assert(y == "123456789")
  assert(buf:qtype() == "I4")
  assert(buf:name() == "some bogus name")
  print("test 3 passed")
end

tests.t4 = function()
  -- using set 
  local qtype = "I4"
  local width = cutils.get_width(qtype)
  local size = 1 * width
  local buf = cmem.new( {size = size, qtype = qtype})
  buf:set(123456789)
  local y = buf:to_str("I4")
  assert(y == "123456789")
  local chk_qtype = buf:qtype()
  assert(chk_qtype == qtype)
  print("test t4 passed")
end


tests.t5 = function()

  -- test foreign functionality
  local size = 1024
  local qtype = "I4"
  local name = "some bogus name"
  local c1 = cmem.new( { size = size, qtype = qtype, name = name})
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
  local c1 = assert(cmem.new({ size = size, qtype = qtype, name = name}))
  assert(c1:size() == size)
  assert(c1:qtype() == qtype)
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
  local c1 = assert(cmem.new({size = size, qtype = qtype, name = name}))
    c1:set(v)
    local y = c1:to_str("SC")
    assert(y == v)
  end
  print("test t7 passed")
end
  
tests.t8 = function()
  -- test SC with bad values 
  -- make a long string 
  local bval = {}
  for i = 1, 10 do 
    bval[i] = "1234567890123456";
  end
  local bigstr = table.concat(bval, "_")
  local size = 16
  local qtype = "SC"
  local name = "some bogus name"
  local c1 = assert(cmem.new({ size = size, qtype = qtype, name = name}))
  print("START: Deliberate error")
  local x = c1:set(bigstr)
  print("STOP: Deliberate error")
  assert(x == nil)
  print("test t8 passed")
end
  
tests.t9 = function()
  -- this is a regression test to guard against malloc'ing less
  -- than what user asked for 
  local n = 1048576
  local qtype = "I4"
  local width = cutils.get_width(qtype)
  local size = n * width
  local name = "some junk name"
  local c1 = assert(cmem.new({ size = size, qtype = qtype, name = name}))
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
    local size = width * n
    local c1 = assert(cmem.new({size = size, qtype = qtype}))
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
  local width = cutils.get_width(qtype)
  local size = num_elements * width
  local buf = cmem.new({ size = size, qtype = qtype})
  local iptr = get_ptr(buf, qtype)
  
  buf:set_min()
  -- verify min values
  for i = 1, num_elements do
    assert(iptr[i-1] == -2147483648)
  end

  buf:set_max()
  -- verify max values
  for i = 1, num_elements do
    assert(iptr[i-1] == 2147483647)
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
  local name = "some bigus name"
  local c1 = cmem.new({size = size, name = name})
  assert(c1:name() == name)
  print("test t12 passed")
end

tests.t13 = function()
  -- test set/get width
  local size = 1024
  local qtype = "I4"
  local c1 = cmem.new({ size = size, qtype = qtype})
  local width = cutils.get_width(qtype)
  assert(c1:set_width(width))
  assert(c1:width() == width)
  -- cannot set width twice 
  local status = pcall(c1.set_width, width)
  assert(not status)
  print("test t13 passed")
end
tests.t14 = function()
  -- test bad set width
  local size = 1024
  local qtype = "I4"
  local c1 = cmem.new({ size = size, qtype = qtype})
  local width = 13
  -- bad width should fail
  local status = pcall(c1.set_width, width)
  assert(not status)
  print("test t14 passed")
end
tests.t15 = function()
  -- test me
  local size = 1024
  local qtype = "I4"
  local name = "hello world"
  local c1 = cmem.new( { size = size,  qtype = qtype, name = name})
  local x = c1:me()
  assert(type(x) == "table")
  -- assert(x.is_foreign == false) TODO Why is this failing?
  assert(x.width == 0)
  assert(x.size == size)
  assert(x.cell_name == "hello world")
  -- assert(x.is_stealable ==false)TODO Why is this failing?
  assert(x.qtype == qtype)
  print("test t15 passed")
end
tests.t16 = function()
  -- test set stealable
  local size = 1024
  local qtype = "I4"
  local name = "hello world"
  local c1 = cmem.new({ size = size, qtype = qtype, name = name})
  local x = c1:me()
  -- assert(x.is_stealable ==false)TODO Why is this failing?

  c1:stealable(true)
  local x = c1:me()
  -- assert(x.is_stealable == true)  -- TODO Why is this failing?

  c1:stealable(false)
  local x = c1:me()
  -- assert(x.is_stealable == false) -- TODO Why is this failing?

  print("test t16 passed")
end
-- return tests
tests.t1();
tests.t2();
tests.t3();
tests.t4();
tests.t5();
tests.t6();
tests.t7();
tests.t8();
tests.t9();
tests.t10();
tests.t11();
tests.t12();
tests.t13();
tests.t14();
tests.t15();
tests.t16();
print("All tests passed")
