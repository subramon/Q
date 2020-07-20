-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q        = require 'Q'
local Scalar   = require 'libsclr'
local cVector  = require 'libvctr'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local chunk_size = cVector.chunk_size()

local tests = {}
tests.t1 = function ()
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local a = Q.mk_col({10, 20, 30, 40, 50}, qtype)
    local b = Q.mk_col({1, 0, 0, 1, 0}, "B1")
    local goodc = Q.mk_col({10, 40}, qtype)
    local c = Q.where(a, b)
    -- assert(c:length() == goodc:length())
    local n1, n2 = Q.sum(Q.vveq(c, goodc)):eval()
    assert(n1 == n2)
  end
  print("Test t1 succeeded")
end
--======================================
tests.t2 = function ()
  local a = Q.mk_col({10, 20, 30, 40, 50}, "I4")
  local b = Q.mk_col({0, 0, 0, 0, 0}, "B1"):set_name("b")
  print(a:length())
  print(b:length())
  assert(Q.where(a, b):set_name("c"):eval() == nil)
  print("Test t2 succeeded")
end
--======================================
tests.t3 = function ()
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local a = Q.mk_col({10, 20, 30, 40, 50}, qtype)
    local b = Q.mk_col({1, 1, 1, 1, 1}, "B1")
    local c = Q.where(a, b)
    local n1, n2 = Q.sum(Q.vveq(a, c)):eval()
    assert(n1 == n2)
  end
  print("Test t3 succeeded")
end
--======================================
tests.t4 = function ()
  local a = Q.mk_col({10, 20, 30, 40, 50}, "I4")
  local b = Q.mk_col({0, 0, 0, 0, 0}, "B1")
  b:set_meta("__min", 0)
  b:set_meta("__max", 0)
  local c = Q.where(a, b)
  assert(c == nil)
  print("Test t4 succeeded")
end
--======================================
tests.t5 = function ()
  local a = Q.mk_col({10, 20, 30, 40, 50}, "I4")
  local b = Q.mk_col({1, 1, 1, 1, 1}, "B1")
  b:set_meta("__min", 1)
  b:set_meta("__max", 1)
  local c = Q.where(a, b)
  assert(c == a)
  print("Test t5 succeeded")
end
--======================================

tests.t6 = function ()
  -- more than chunk size values present in a and b
  local len = chunk_size + 1
  local b = lVector.new({qtype = "B1"})
  local sone = Scalar.new(1, "B1")
  for i = 1, chunk_size do 
    b:put1(sone)
  end
  b:put1(Scalar.new(1, "B1"))
  b:eov()

  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local a = Q.const( {val = 1, qtype = qtype, len = len} )
    local c = Q.where(a, b)
    local n1, n2 = Q.sum(c):eval()
    assert(n1 == Scalar.new(len))
  end
  print("Test t6 succeeded")
end
--=========================================

tests.t7 = function ()
  -- more than chunk size values present in a and b
  local chunk_sz = cVector.chunk_size()
  local len = chunk_sz * 2 + 5
  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = len} )
  local b = lVector.new({qtype = "B1"})
  local s1 = Scalar.new(1, "B1")
  local s0 = Scalar.new(0, "B1")
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
  local c = Q.where(a, b):eval()
  len = math.floor(len / 2) + 1 
  local d = Q.seq( {start = 1, by = 2, qtype = "I4", len = len} )
  local n1, n2 = Q.sum(Q.vveq(c, d)):eval()
  assert(n1 == n2)
  print("Test t7 succeeded")
end

-- tests.t1()
return tests
