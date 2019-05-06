-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local lVector = require 'Q/RUNTIME/lua/lVector'
Scalar = require 'libsclr'

local tests = {}
tests.t1 = function ()

  local alen = 2*32 -- make this a multiple of 32
  local blen = alen / 32 -- 32 bits in an I4
  local oldval = 10
  local newval = 10000
  local a = Q.const( {val = oldval, qtype = "I4", len = alen} ):set_name("a")
  -- Create binary vector b through Q.rand
  local b = Q.rand( { lb = 100, ub = 200, qtype = "I4", len = blen } ):set_name("b")
  
  -- b must be eval'd before we can cast it 
  local status = pcall(Q.cast, b, "B1")
  assert(not status)

  b:eval()
  local b1 = Q.cast(b, "B1")

  status = pcall(lVector.make_nulls, a, b1)
  assert(not status)

  a:eval()
  b1:set_name("b1")
  a:make_nulls(b1)

  local s2 = Q.sum(b1):eval():to_num()
  print("number of 1's = ", s2)
  local c = Q.drop_nulls(a, Scalar.new(newval, "I4"))
  assert(Q.sum(c):eval():to_num() == 
    ((s2 * oldval) + ( (a:length() - s2) * newval)))
end
  --=======================================
return tests


