-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
-- aim is to perform a conditional associative operation
-- sum_i X_i where Y_i = true 
  local len = 16 -- make sure that this is a multiple of 4
  local c1 = Q.seq({ len = len, qtype = "I4", start = 1, by = 1})
  local c2 = Q.period({start = 0, by = 1, period = 2, qtype = "I4", len = len })
  local c3 = Q.convert(c2, "B1")
  local c4 = Q.where(c1, c3)
  local s5 = Q.sum(c4)
  local x, y = s5:eval()
  -- correct_answer = 2 + 4 + .... len = 2 * ( 1 + 2 + 3 + .. len/2)
  local correct_answer =   (len/2)*(len/2+1)
  assert(x:to_num() == correct_answer, "expected " .. correct_answer)
  assert(y:to_num() == len/2)
  local opt_args = { opfile = "" }
  --Q.print_csv({c1, c2, c3}, opt_args)
end
return tests
