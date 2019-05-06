-- SANITY TEST
-- ## Assertion: t1: exp(log(x)) == x
-- ## Assertion: t2: (1/(1/x)) == x
-- ## Assertion: t3: sqr(sqrt(x)) == x

-- Library Calls
local Q = require 'Q'
local Scalar = require 'libsclr' -- TODO Remove this. Ask Indrajeet
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  local qtypes = { "F8", "F4" }
  local len = 100000
  for k, qtype in ipairs(qtypes) do 
    local x = Q.rand( { lb = 1, ub = 10, qtype = qtype, len = len})
    assert(Q.vvseq(
             Q.log(
               Q.exp(x)
             ),
             x,
	     Scalar.new(0.10, qtype),
             { mode = "ratio" }
           )
         )
  end
  print("Success for t1")
end
tests.t2 = function ()
  local qtypes = { "F8", "F4" }
  local len = 100000
  for k, qtype in ipairs(qtypes) do 
    local x = Q.rand( { lb = 0.25, ub = 4, qtype = qtype, len = len})
    assert(Q.vvseq(
             Q.reciprocal(
               Q.reciprocal(x)
             ),
             x,
	     Scalar.new(0.10, qtype),
             { mode = "ratio" }
           )
         )
  end
  print("Success for t2")
end
--======================================
tests.t3 = function ()
  local qtypes = { "F4", "F8" }
  local len = 10; local lb = 10; local ub = 100
  for k, qtype in ipairs(qtypes) do 
    local x = Q.rand( { lb = lb, ub = ub, qtype = qtype, len = len})
    assert(Q.vvseq(
             Q.vvmul(
               Q.sqrt(x),
               Q.sqrt(x)
             ),
             x,
	     Scalar.new(0.10, qtype),
             { mode = "ratio" }
           )
         )
  end
  print("Success for t3")
end
--======================================
tests.t4 = function ()
  local qtypes = { "I1", "I2", "I4","I8", "F4", "F8" }
  local len = 100000; local lb = -127; local ub = 126
  for k, qtype in ipairs(qtypes) do 
    local s
    if ( ( qtype == "F4" ) or ( qtype == "F8" ) ) then 
      s =  Scalar.new(0.001, qtype)
    else
      s =  Scalar.new(0, qtype)
    end
    local x = Q.rand( { lb = lb, ub = ub, qtype = qtype, len = len})
    assert(Q.vvseq(
             Q.incr(
               Q.decr(x)
             ),
             x,
	     s,
             { mode = "difference" }
           )
         )
  end
  print("Success for t4")
end
--======================================
return tests

