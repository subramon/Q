-- FUNCTIONAL
local Q        = require 'Q'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local conjoin  = require 'Q/RUNTIME/lua/conjoin'
local lr_logit = require 'Q/ML/LOGREG/lua/lr_logit'

local tests = {}
local len = qconsts.chunk_size * 3

-- checking of eval() which is called on l1 vector
-- should also evaluate its sibling vectors
tests.t1 = function()
  local x = Q.rand( { lb = 0.1, ub = 0.9, qtype = "F8", len = len } ):set_name("x")
  x:eval()
  local l1, l2 = lr_logit(x)
  conjoin({l1, l2})
  -- calling eval() on l1
  l1:eval()
  assert(l1:length() == l2:length())
  print("Test t1 succeeded")
end

-- checking of chunk() which is called on l1 vector
-- should also evaluate its sibling vectors
tests.t2 = function()
  local x = Q.rand( { lb = 0.1, ub = 0.9, qtype = "F8", len = len } ):set_name("x")
  x:eval()
  local l1, l2 = lr_logit(x)
  conjoin({l1, l2})
  -- calling chunk() on l1
  local chunk_num = 0
  local base_len, base_addr, nn_addr 
  repeat
    base_len, base_addr, nn_addr = l1:chunk(chunk_num)
    chunk_num = chunk_num + 1 
  until ( base_len ~= qconsts.chunk_size )
  assert(l1:length() == l2:length())
  print("Test t2 succeeded")
end

return tests