cmem   = require 'libcmem' ; 
Scalar = require 'libsclr' ; 
num_trials = 32 -- 1024
tbl_size = 4096 -- 1048576
cmem   = require 'libcmem' ; 
local tests = {}
tests.t1 = function()
  -- create boolean scalars in several different ways
  sb = assert(Scalar.new("true", "B1"))
  sb = assert(Scalar.new(true, "B1"))
  x = assert(Scalar.to_str(sb))
  assert(x == "true")
  sb = Scalar.new("false", "B1")
  assert(Scalar.to_str(sb) == "false")
  assert(sb:fldtype() == "B1")
  print("test 1 passed")
end

--================
tests.t2 = function()
  -- create integer and floating point scalars
  s1 = Scalar.new(123, "I4")
  assert(Scalar.to_num(s1) == 123)

  s2 = Scalar.new("123", "F4")
  assert(Scalar.to_num(s2) == 123)

  s3 = Scalar.new(123.456, "F8")
  assert(Scalar.to_num(s3) == 123.456)
  -- TODO y = x:to_str(x, "I4")
  -- TODO assert(y == "123")
  --================
  assert(Scalar.eq(s1, s2) == true)
  assert(Scalar.eq(s1, s3) == false)
  print("test 2 passed")
end

tests.t3 = function()
  for i = 1, num_trials do
    x = {}
    for j = 1, tbl_size do
      in_val = i+j/10.0;
      x[j] = Scalar.new(in_val, "F4")
      out_str = Scalar.to_str(x[j])
      out_val = tonumber(out_str)
      assert( math.abs((out_val - in_val))/out_val < 0.001)
    end
  end
  print("test 3 passed")
end
tests.t4 = function()
  -- testing userdata and creation of scalar from CMEM
  qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
  for _, qtype in ipairs(qtypes) do
    local val = 123
    local s1 = Scalar.new(val, qtype)
    local c1 = cmem.new(8, qtype, "test cmem")
    c1:set(val);
    local s2 = assert(Scalar.new(c1, qtype))
    assert(Scalar.eq(s1, s2) == true)
  end
  print("test 4 passed")
end
tests.t5 = function()
  -- test very small and very large numbers
  local X = { 
    I1 = { "127", "-128"}, 
    I2 = { "32767", "-32768"}, 
    I4 = { "2147483647", "-2147483648"}, 
    I8 = { "9223372036854775807", "-9223372036854775808"}, 
    F4 = { "1.175494e-38", "3.402823e+38" },
    F8 = { "2.225074e-308", "1.797693e+308" },
  }
  -- TODO Why is this not working?????
  for qtype, v in pairs(X) do
    for _, val in ipairs(v) do 
      local s = assert(Scalar.new(val, qtype))
    end
  end
  print("test 5 passed")
end
tests.t6 = function ()
  local vals = { 127, -128 }
  local orig_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" } 
  local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" } 
  for _, orig_qtype in pairs(orig_qtypes) do 
    for _, val in pairs(vals) do 
      for _, qtype in pairs(qtypes) do 
        s1 = Scalar.new(val, orig_qtype)
        s2 = s1:conv(qtype)
        assert(s1:fldtype() == qtype)
        assert(s1 == s2)
        print(orig_qtype, qtype, val, s2)
        assert(s2:to_num() == val)
      end
    end
  end
  print("test 6 passed")
end
tests.t7 = function()
  -- WRite like t6 but try to make the conversion fail 
  -- in as many cases as possible
  --assert(nil, "UTPAL TODO")
  local vals = { 127, -128 }
  local orig_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" } 
  local qtypes = { "SC", "SV", "B1" } 
  print("START: Deliberate error")
  for _, orig_qtype in pairs(orig_qtypes) do 
    for _, val in pairs(vals) do 
      for _, qtype in pairs(qtypes) do 
        s1 = Scalar.new(val, orig_qtype)
        local status = s1:conv(qtype)
        assert(not status)
      end
    end
  end
  print("STOP : Deliberate error")
  print("test 7 passed")
end
tests.t8 = function()
 -- just bad values 
  local status, err
  print("START: Deliberate error")
  status, err = Scalar.new("128", "I1"); assert(not status)
  status, err = Scalar.new("-129", "I1"); assert(not status)

  status, err = Scalar.new("32768", "I2"); assert(not status)
  status, err = Scalar.new("-32769", "I2"); assert(not status)

 -- TODO complete 

  print("STOP : Deliberate error")
  print("test 8 passed")
end
tests.t9 = function()
  -- test arithmetic operators 
  local s1 = Scalar.new("123", "I1")
  local s2 = Scalar.new("123", "I1") 
  assert(s1 == s2)
  s2 = Scalar.new("124", "I1") 
  assert(s1 < s2)
  s2 = Scalar.new("122", "I1") 
  assert(s1 > s2)
  s1 = Scalar.new("123", "I2")
  s2 = Scalar.new("123", "I2") 
  local s3 = s1 + s2
  assert(s3:to_num() == 2*123)
  s3 = s1 - s2
  assert(s3:to_num() == 0)
end
-- 
tests.t10_I1 = function()
  -- Test boundary cases of conversion, both success and failure
  local qtypes = { "I2", "I4", "I8", "F4", "F8" } 
  for _, qtype in ipairs(qtypes) do
    local s1 = Scalar.new("127", qtype)
    assert(s1:conv("I1"), " should work qtype = " .. qtype)
    local s1 = Scalar.new("-128", qtype)
    assert(s1:conv("I1"), " should work qtype = " .. qtype)
  end
  print("START Deliberate error")
  for _, qtype in ipairs(qtypes) do
    local s1 = Scalar.new("128", qtype)
    local s2 = s1:conv("I1")
    assert(not s2, " should not work qtype = " .. qtype)
    local s1 = Scalar.new("-129", qtype)
    local s2 = s1:conv("I1")
    assert(not s2, " should not work qtype = " .. qtype)
  end
  print("STOP  Deliberate error")
end
tests.t10_I2 = function()
  -- Test boundary cases of conversion, both success and failure
  local qtypes = { "I4", "I8", "F4", "F8" } 
  for _, qtype in ipairs(qtypes) do
    local s1 = Scalar.new("32767", qtype)
    assert(s1:conv("I2"), " should work qtype = " .. qtype)
    local s1 = Scalar.new("-32768", qtype)
    assert(s1:conv("I2"), " should work qtype = " .. qtype)
  end
  print("START Deliberate error")
  for _, qtype in ipairs(qtypes) do
    local s1 = Scalar.new("32768", qtype)
    local s2 = s1:conv("I2")
    assert(not s2, " should not work qtype = " .. qtype)
    local s1 = Scalar.new("-32769", qtype)
    local s2 = s1:conv("I2")
    assert(not s2, " should not work qtype = " .. qtype)
  end
  print("STOP  Deliberate error")
end
tests.t10_I4 = function()
  -- Test boundary cases of conversion, both success and failure
  local qtypes = { "I8", "F8" } 
  for _, qtype in ipairs(qtypes) do
    local s1 = Scalar.new("2147483647", qtype)
    assert(s1:conv("I4"), " should work qtype = " .. qtype)
    local s1 = Scalar.new("-2147483648", qtype)
    assert(s1:conv("I4"), " should work qtype = " .. qtype)
  end

  local s1 = Scalar.new(16777217, "F4")
  local s2 = assert(s1:conv("I4"))
  assert(s1 == s2)

  print("START Deliberate error")
  for _, qtype in ipairs(qtypes) do
    local s1 = Scalar.new("2147483648", qtype)
    local s2 = s1:conv("I4")
    assert(not s2, " should not work qtype = " .. qtype)
    local s1 = Scalar.new("-2147483649", qtype)
    local s2 = s1:conv("I4")
    assert(not s2, " should not work qtype = " .. qtype)
  end
  print("STOP  Deliberate error")
end
tests.t10_I8 = function()
  local s1 = Scalar.new(9007199254740993, "F8")
  local s2 = assert(s1:conv("I8"))
  assert(s1 == s2)
end

tests.t11 = function()
  local s1 = Scalar.new(127, "I1") 
  local s2 = Scalar.new(-127, "I1")
  local s3 = s2:abs()
  assert(s1 == s3)
 --==========
  assert(Scalar.new(32767, "I2") == Scalar.new(-32767, "I2"):abs())
  assert(Scalar.new(2147483647, "I4") == Scalar.new(-2147483647, "I4"):abs())
  -- TODO Utpal 
  -- Write tests for I8/F4/F8
  s1 = Scalar.new(1.79769313486231470e+308, "F8")
  s2 = Scalar.new(-1.79769313486231470e+308, "F8")
  local s3 = s2:abs()
  assert(s1 == s3)
end

tests.t12 = function()
  -- negative cases for boolean scalars in several different ways
  bval = {}
  bval[#bval+1] = "truex"
  bval[#bval+1] = "True"
  bval[#bval+1] = "TRUE"
  bval[#bval+1] = "falsey"
  bval[#bval+1] = "False"
  bval[#bval+1] = "FALSE"
  bval[#bval+1] = " true "


  for k, v in ipairs(bval) do 
    print("START: Deliberate error")
    local s1 = Scalar.new(bval, "B1")
    print("STOP: Deliberate error")
    assert(s1 == nil)
  end
  print("test 12 passed")
end

tests.t13 = function()
  -- compare number and scalar
  -- TODO DOES NOT WORK RIGHT NOW UNTIL QQ-151 is solved
--[[
  local x = Scalar.new(1, "I1")
  local y = Scalar.new(1, "I1")
  local z = x + y
  local z = x + 1
  assert(x == y )
  assert(x == 1 )
  local z = ( x + 1 )
  --]]
  return true
end
tests.t14 = function()
  local f4 = Scalar.new(0.11, "F4")
  print("Scalar = ",f4)
  print("to_num",f4:to_num())
  print("abs", f4:abs():to_num())
  --[[
  This produces the following output.
  Scalar =  1.100000e-01
  to_num  0.10999999940395
  abs 0.10999999940395
  
  It appears incorrect but in fact it is. Run the following program in the 
  debugger and inspect the values of w,x,y,z to convince yourself
  
  #include <stdio.h>
  int
  main()
  {
    float w = 0.11;
    double x = 0.11;
    float y = x;
    float z = (float)x;
    printf("hello world\n");
  }
  --]]
end
--================
tests.t15 = function()
  local valI8 = Scalar.new("0x1", "I8")
  print("Scalar = ",valI8)
end
return tests
