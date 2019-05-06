-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q        = require 'Q'
local Scalar   = require 'libsclr'
local lr_logit = require 'Q/ML/LOGREG/lua/lr_logit'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local conjoin  = require 'Q/RUNTIME/lua/conjoin'

local tests = {}
tests.t1 = function(
  no_memo,
  is_conjoin
  )
  if ( not no_memo    ) then no_memo    = false end 
  if ( not is_conjoin ) then is_conjoin = false end 
  local tolerance = 0.0001
  local len
  len = 2*qconsts.chunk_size + 17
  len = qconsts.chunk_size
  local x = Q.rand( { lb = 0.1, ub = 0.9, qtype = "F8", len = len } ):set_name("x")
  local t3_a = Q.logit(x):set_name("t3_a"):eval()
  local t4_a = Q.logit2(x):set_name("t4_a"):eval()
  -- TODO P1: Does not work when using true instead of false for lr_logit
  local t3_b, t4_b = lr_logit(x, no_memo)
  if ( is_conjoin ) then 
    conjoin({t3_b, t4_b})
  end
  t3_b:eval()
  print("t3", t3_b:is_eov())
  print("t4", t4_b:is_eov())
  if ( no_memo  == false ) then 
    assert(t4_b:is_eov() == true)
  elseif ( is_conjoin == false ) then
    assert(t4_b:is_eov() == false)
  else
    assert(t4_b:is_eov() == true)
  end
  t4_b:eval()
  print("=====================================")
  assert(Q.vvseq(t3_a, t3_b, Scalar.new(tolerance, "F8")))
  assert(Q.vvseq(t4_b, t4_b, Scalar.new(tolerance, "F8")))
  print("Test t1 succeeded")
end
tests.t2 = function(
  )
  tests.t1(true, false)
  print("Test t2 succeeded")
end
tests.t3 = function(
  )
  tests.t1(true, true)
  print("Test t3 succeeded")
end
return tests
