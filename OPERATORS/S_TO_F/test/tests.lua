-- FUNCTIONAL 
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'
local tests = {}
--=================================================
tests.test_seed = function()
  local len = 2*qconsts.chunk_size + 17
  -- len = qconsts.chunk_size - 17
  local seed = 12345678
  local qtype = "I4"
  local lb = 1
  local ub = 10
  local c1 = Q.rand( 
    {seed = seed, lb = lb, ub = 10, qtype = qtype, len = len })
  local c2 = Q.rand( 
    {seed = seed, lb = lb, ub = 10, qtype = qtype, len = len })
  local n1, n2 = Q.sum(Q.vveq(c1, c2)):eval()
  Q.print_csv({c1, c2}, {opfile = "_x.csv"})
  -- print(n1, n2)
  assert(n1 == n2)
  require('Q/UTILS/lua/cleanup')()
  print("Test test_seed completed")
end
--=================================================
tests.test_const = function()
  local num = (2048*1048576)-1
  local c1 = Q.const( {val = num, qtype = "I4", len = 8 })
  local minval = Q.min(c1):eval()
  local maxval = Q.max(c1):eval()
  assert(minval == maxval) 
  assert(minval:to_num() == num)
  assert(maxval:to_num() == num)
  require('Q/UTILS/lua/cleanup')()
end
--=================================================
tests.test_period = function()
  local n = 32768+10923
  print("n = ", n)
  local len = n * 3 
  local y = Q.period({start = 1, by = 2, period = 3, qtype = "I4", len = len })
  local actual = Q.sum(y):eval()
  local expected = (n * (1+3+5))
  assert (actual:to_num() == expected ) 
  -- local opt_args = { opfile = "" }
  -- TODO Krushnakant: Q.print_csv(y, opt_args)
  require('Q/UTILS/lua/cleanup')()
end
--========================================
tests.test_rand_B1 = function()
  local len = 65536 * 4 
  local p = 0.25;
  local actual = Q.sum(Q.rand( { probability = p, qtype = "B1", len = len })):eval():to_num()
  local expected = len * p
  print("len,p,actual,expected", len, p, actual, expected)
  assert( ( ( actual >= expected * 0.90 ) and
       ( actual <= expected * 1.10 ) ) )
  require('Q/UTILS/lua/cleanup')()
end
--=======================================
tests.generic = function()
  local z = Q.const( { val = 5, qtype = "I4", len = 10 })
  local minval = Q.min(z):eval()
  local maxval = Q.max(z):eval()
  assert(minval == maxval)
  assert(minval:to_num() == 5)
  assert(maxval:to_num() == 5)
  --========================================
  z = Q.rand( { lb = 100, ub = 200, seed = 1234, qtype = "I4", len = 10 })
  minval = Q.min(z):eval():to_num()
  maxval = Q.max(z):eval():to_num()
  assert(minval >= 100)
  assert(maxval <= 200)
  --========================================
  z = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 3 } )
  minval = Q.min(z):eval():to_num()
  maxval = Q.max(z):eval():to_num()
  assert(minval >= 0)
  assert(maxval <= 1)
  --========================================
  z = Q.seq( {start = -1, by = 5, qtype = "I4", len = 10} )
  minval = Q.min(z):eval()
  maxval = Q.max(z):eval()
  assert(minval:to_num() == -1)
  assert(maxval:to_num() == 44)
  --=======================================
  require('Q/UTILS/lua/cleanup')()
end

return tests
