local qc     = require 'Q/UTILS/lua/q_core'
local cmem   = require 'libcmem'
local ffi    = require 'ffi' 
local Scalar = require 'libsclr' 
local tests = {}
local get_ptr = require 'Q/UTILS/lua/get_ptr'
tests.t1 = function()
  local num_iters = 1000000
  for i = 1, num_iters do 
    local s1 = assert(Scalar.new(i, "I4"))
    local c1 = s1:to_cmem()
    assert(type(c1) == "CMEM")
    local ptr = get_ptr(c1, "I4")
    assert(ptr[0] == i)
    ptr[0] = i+1
    assert(ptr[0] == i+1)
  end
  print("test 1 passed")
end
--================
tests.t2 = function()
ffi.cdef([[
  typedef struct _some_struct {
  bool    B1;
  int8_t  I1;
  int16_t I2;
  int32_t I4;
  int64_t I8;
  float   F4;
  double  F8;
} some_struct;
]]
)
  local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8", "B1" }
  local cnt = 1
  local c = cmem.new(ffi.sizeof("some_struct"))
  c2 = ffi.cast("some_struct *", c)
  for _, qtype in pairs(qtypes) do
    local s
    if ( qtype == "B1" ) then 
      s = Scalar.new("true", qtype)
    else
      s = Scalar.new(cnt, qtype)
    end
    local s2 = ffi.cast("SCLR_REC_TYPE *", s)
    local kc  = qtype
    local ks = "val" .. qtype
    c2[0][kc] = s2[0].cdata[ks]
    cnt = cnt + 1 
  end
  print("=======")
  for _, qtype in pairs(qtypes) do
    print(c2[0][qtype])
  end
  for _, qtype in pairs(qtypes) do
    if ( qtype == "F8" ) then assert(c2[0][qtype] == 6 ) end 
    if ( qtype == "B1" ) then assert(c2[0][qtype] == true ) end 
    if ( qtype == "I1" ) then assert(c2[0][qtype] == 1 ) end 
    if ( qtype == "I2" ) then assert(c2[0][qtype] == 2 ) end 
    if ( qtype == "I4" ) then assert(c2[0][qtype] == 3 ) end 
    if ( qtype == "I8" ) then assert(c2[0][qtype] == 4 ) end 
    if ( qtype == "F4" ) then assert(c2[0][qtype] == 5 ) end 
    if ( qtype == "F8" ) then assert(c2[0][qtype] == 6 ) end 
  end
end
--================
return tests
-- tests.t2()
-- os.exit()
