-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q        = require 'Q'
local Scalar   = require 'libsclr'
local cVector  = require 'libvctr'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qcfg     = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk 

local tests = {}
tests.t1 = function ()
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local a = Q.mk_col({10, 20, 30, 40, 50}, qtype)
    local b = Q.mk_col({1, 0, 0, 1, 0}, "BL")
    local goodc = Q.mk_col({10, 40}, qtype)
    local c = Q.where(a, b):eval()
    assert(c:num_elements() == goodc:num_elements())
    -- TODO local n1, n2 = Q.sum(Q.vveq(c, goodc)):eval()
    -- TODO assert(n1 == n2)
  end
  cVector:check_all(true, true)
  print("Test t1 succeeded")
end
--======================================
tests.t2 = function ()
  local a = Q.mk_col({10, 20, 30, 40, 50}, "I4")
  local b = Q.mk_col({0, 0, 0, 0, 0}, "BL"):set_name("b")
  assert(a:num_elements() == b:num_elements())
  local c = Q.where(a, b):set_name("c")
  assert(type(c) == "lVector")
  c:eval()
  assert(c:num_elements() == 0)
  cVector:check_all(true, true)
  print("Test t2 succeeded")
end
--======================================
tests.t3 = function ()
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local a = Q.mk_col({10, 20, 30, 40, 50}, qtype)
    local b = Q.mk_col({1, 1, 1, 1, 1}, "BL")
    local c = Q.where(a, b)
    c:eval(); 
    assert(c:num_elements() == b:num_elements())
    -- TODO local n1, n2 = Q.sum(Q.vveq(a, c)):eval()
    -- TODO assert(n1 == n2)
  end
  print("Test t3 succeeded")
end
--======================================
tests.t4 = function ()
  local a = Q.mk_col({10, 20, 30, 40, 50}, "I4")
  local b = Q.mk_col({0, 0, 0, 0, 0}, "BL")
  b:set_meta("min", Scalar.new(0, "I4"))
  b:set_meta("max", Scalar.new(0, "I4"))
  local c = Q.where(a, b)
  print(type(c))
  assert(c == nil)
  print("Test t4 succeeded")
end
--======================================
tests.t5 = function ()
  local a = Q.mk_col({10, 20, 30, 40, 50}, "I4")
  local b = Q.mk_col({1, 1, 1, 1, 1}, "BL")
  b:set_meta("min", Scalar.new(1, "I4"))
  b:set_meta("max", Scalar.new(1, "I4"))
  local c = Q.where(a, b)
  assert(c == a)
  print("Test t5 succeeded")
end
--======================================

tests.t6 = function ()
  -- more than chunk size values present in a and b
  local n = max_num_in_chunk + 1
  local b = lVector.new({qtype = "BL"})
  local sone  = Scalar.new(1, "BL")
  local szero = Scalar.new(0, "BL")
  local num_in_c = 0
  for i = 1, n do 
    if ( ( i % 2 ) == 0 ) then
      b:put1(sone)
      num_in_c = num_in_c + 1 
    else
      b:put1(szero)
    end
  end
  b:eov()

  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local a = Q.const( {val = 1, qtype = qtype, len = n} )
    local c = Q.where(a, b)
    c:eval() 
    assert(c:num_elements() == num_in_c)
    -- TODO local n1, n2 = Q.sum(c):eval()
    -- TODO assert(n1 == Scalar.new(len))
  end
  print("Test t6 succeeded")
end
--=========================================

tests.t7 = function ()
  -- more than max_num_in_chunk  values present in a and b
  local max_num_in_chunk = 64 
  local len = max_num_in_chunk * 2 + 5
  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = len,
  max_num_in_chunk = max_num_in_chunk} )
  a:eval()
  local b = lVector.new({qtype = "BL", max_num_in_chunk = max_num_in_chunk} )
  local s1 = Scalar.new(1, "BL")
  local s0 = Scalar.new(0, "BL")
  local toggle = true
  for i = 1, len do 
    if ( toggle ) then
      b:put1(s1)
      toggle = false
    else
      b:put1(s0)
      toggle = true
    end
  end
  b:eov()

  assert(a:max_num_in_chunk() == max_num_in_chunk)
  assert(b:max_num_in_chunk() == max_num_in_chunk)

  assert(a:num_elements()== len)
  assert(b:num_elements() == len)

  local c = Q.where(a, b, { max_num_in_chunk = max_num_in_chunk / 4 } ):eval()
  len = math.floor(len / 2) + 1 
  -- TODO local d = Q.seq( {start = 1, by = 2, qtype = "I4", len = len} )
  -- TODO local n1, n2 = Q.sum(Q.vveq(c, d)):eval()
  -- TODO assert(n1 == n2)
  c:eval()
  assert(c:num_elements() == 67)
  print("Test t7 succeeded")
end

tests.t1()
tests.t2()
tests.t3()
tests.t4()
tests.t5()
tests.t6()
tests.t7()
os.exit()
-- return tests
