local Q         = require 'Q'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local tests = {}

tests.t1 = function()
  local n = 65

  local x = Q.seq( {start = 0, by = 1, qtype = "I4", len = n} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = n} )
  local z = Q.concat(x, y)
  local x1, y1 = Q.split(z)
  x1:eval()
  -- y1:eval() -- TODO Why is this needed? Should not be

  assert(x1:fldtype() == x:fldtype())
  assert(y1:fldtype() == y:fldtype())

  assert(x1:length() == x:length())
  assert(y1:length() == y:length())

  -- Q.print_csv({x, y, z, x1, y1})

  local n1, n2 = Q.sum(Q.vveq(x, x1)):eval()
  assert(n1:to_num() == n)
  assert(n2:to_num() == n)
  local n1, n2 = Q.sum(Q.vveq(y, y1)):eval()
  assert(n1:to_num() == n)
  assert(n2:to_num() == n)

  print("Successfully completed t1")
end

-- Positive Test-case: checking for num_elements > chunk_size
tests.t2 = function()
  local n = qconsts.chunk_size + 10
  local x = Q.seq( {start = 0, by = 1, qtype = "I4", len = n} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = n} )
  local z = Q.concat(x, y)
  z:eval()
  local x1, y1 = Q.split(z)
  x1:eval()
  assert(x1:fldtype() == x:fldtype())
  assert(y1:fldtype() == y:fldtype())

  assert(x1:length() == x:length())
  assert(y1:length() == y:length())

  local n1, n2 = Q.sum(Q.vveq(x, x1)):eval()
  assert(n1:to_num() == n)
  assert(n2:to_num() == n)
  local n1, n2 = Q.sum(Q.vveq(y, y1)):eval()
  assert(n1:to_num() == n)
  assert(n2:to_num() == n)
  print("Successfully completed t2")
end

return tests
